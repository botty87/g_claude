# g_claude — Justfile
# ====================
# Command runner for Clyde (macOS-first Flutter desktop GUI for Claude Code).
#
# Usage: just <recipe>           # run a recipe
#        just --list             # list all recipes
#        just --show <recipe>    # show a recipe definition

# Default — list recipes
default:
    @just --list --unsorted

# ==============================================================================
# CONFIGURATION
# ==============================================================================

project_root := justfile_directory()
lib_path := project_root / "lib"
features_path := lib_path / "features"
l10n_tool := lib_path / "core" / "l10n" / "tool" / "l10n_generate.dart"
release_app := project_root / "build" / "macos" / "Build" / "Products" / "Release" / "Clyde.app"
release_dir := project_root / "release"
strip_fonts_script := project_root / "scripts" / "strip_unused_symbol_fonts.sh"

flutter := "fvm flutter"
dart := "fvm dart"

# ==============================================================================
# FLUTTER ESSENTIALS
# ==============================================================================

# Run app (debug, default device)
run *args:
    {{flutter}} run -d macos {{args}}

# Run release locally (debug-with-aot — useful to test perf without build)
run-release *args:
    {{flutter}} run -d macos --release {{args}}

# Run profile mode for performance profiling
run-profile *args:
    {{flutter}} run -d macos --profile {{args}}

# List available devices
devices:
    {{flutter}} devices

# Show Flutter/Dart versions
versions:
    @echo "=== FVM Flutter ==="
    @{{flutter}} --version
    @echo ""
    @echo "=== Dart ==="
    @{{dart}} --version

# Doctor check
doctor:
    {{flutter}} doctor -v

# ==============================================================================
# RELEASE BUILD (macOS)
# ==============================================================================

# Bundle the Agent SDK sidecar into a single self-contained .cjs (esbuild)
build-sidecar:
    cd {{project_root}}/backend && npm run bundle

# Build macOS release app: bundle sidecar, build, embed sidecar in Resources,
# strip unused Symbol font variants (~27MB saved)
build-mac: build-sidecar
    {{flutter}} build macos --release --no-tree-shake-icons
    cp "{{project_root}}/backend/dist/clyde-sidecar.cjs" "{{release_app}}/Contents/Resources/clyde-sidecar.cjs"
    bash {{strip_fonts_script}} {{release_app}}
    @echo ""
    @echo "=== Build complete ==="
    @du -sh {{release_app}}
    @echo "Path: {{release_app}}"

# Build + open the release .app
build-mac-open: build-mac
    open {{release_app}}

# Show current version from pubspec
version:
    @grep '^version:' pubspec.yaml | sed 's/version: //'

# Pre-flight: ensure clean tree, branch=main, in sync with origin
[private]
release-guard:
    #!/usr/bin/env bash
    set -euo pipefail
    branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "main" ]; then
        echo "ERROR: must be on 'main', currently on '$branch'."
        exit 1
    fi
    if [ -n "$(git status --porcelain)" ]; then
        echo "ERROR: working tree not clean. Commit or stash first."
        git status --short
        exit 1
    fi
    git fetch origin main --quiet
    local_sha=$(git rev-parse HEAD)
    remote_sha=$(git rev-parse origin/main)
    if [ "$local_sha" != "$remote_sha" ]; then
        echo "ERROR: local 'main' diverges from origin/main. Pull/push first."
        exit 1
    fi
    echo "Pre-flight OK (clean main, in sync)."

# Bump build number only (e.g. 1.0.0+1 → 1.0.0+2)
bump-build:
    #!/usr/bin/env bash
    set -euo pipefail
    current=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    name="${current%%+*}"
    build="${current##*+}"
    new_build=$((build + 1))
    new_version="${name}+${new_build}"
    sed -i '' "s/^version: .*/version: ${new_version}/" pubspec.yaml
    echo "Version: ${current} → ${new_version}"

# Bump version part (major|minor|patch) and increment build number
[private]
bump-version part:
    #!/usr/bin/env bash
    set -euo pipefail
    current=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    name="${current%%+*}"
    build="${current##*+}"
    new_build=$((build + 1))
    IFS='.' read -r major minor patch <<< "$name"
    case "{{part}}" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        patch) patch=$((patch + 1)) ;;
        *) echo "Invalid part: {{part}}. Use major, minor, or patch."; exit 1 ;;
    esac
    new_version="${major}.${minor}.${patch}+${new_build}"
    sed -i '' "s/^version: .*/version: ${new_version}/" pubspec.yaml
    echo "Version: ${current} → ${new_version}"

# Commit pubspec bump only (no tag) — used by release-build
[private]
commit-bump:
    #!/usr/bin/env bash
    set -euo pipefail
    ver=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    git add pubspec.yaml
    git commit -m "build: bump build number to ${ver}"
    echo "Committed: ${ver}"

# Commit pubspec + create annotated tag vX.Y.Z (no push)
tag:
    #!/usr/bin/env bash
    set -euo pipefail
    ver=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    tag="v${ver%%+*}"
    if git rev-parse "$tag" >/dev/null 2>&1; then
        echo "Tag $tag already exists, skipping."
    else
        git add pubspec.yaml
        git commit -m "build: bump version to ${ver}"
        git tag -a "$tag" -m "Release $tag"
        echo "Committed and tagged: $tag"
    fi

# Package .app → zip + sha256 + draft release notes under release/vX.Y.Z/
[private]
package-release:
    #!/usr/bin/env bash
    set -euo pipefail
    ver=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    tag="v${ver%%+*}"
    out_dir="{{release_dir}}/${tag}"
    zip_name="Clyde-${tag}-macos.zip"
    mkdir -p "${out_dir}"
    if [ ! -d "{{release_app}}" ]; then
        echo "ERROR: {{release_app}} not found. Run 'just build-mac' first."
        exit 1
    fi
    echo "Packaging ${zip_name}..."
    rm -f "${out_dir}/${zip_name}"
    ditto -c -k --sequesterRsrc --keepParent "{{release_app}}" "${out_dir}/${zip_name}"
    ( cd "${out_dir}" && shasum -a 256 "${zip_name}" > SHA256SUMS.txt )
    prev_tag=$(git describe --tags --abbrev=0 --exclude="${tag}" 2>/dev/null || echo "")
    if [ -z "${prev_tag}" ] && [ "${tag}" != "v1.0.0" ]; then
        echo "WARN: no prior tag found for ${tag}; release notes will say 'Initial release'." >&2
    fi
    notes="${out_dir}/RELEASE_NOTES.md"
    if [ -f "${notes}" ]; then
        echo "RELEASE_NOTES.md already exists, leaving untouched."
    else
        {
            echo "# Clyde ${tag}"
            echo ""
            echo "_Released $(date +%Y-%m-%d)_"
            echo ""
            echo "## Changes"
            echo ""
            if [ -n "${prev_tag}" ]; then
                git log "${prev_tag}..HEAD" --pretty=format:'- %s' --no-merges
                echo ""
            else
                echo "- Initial release."
            fi
            echo ""
            echo "## Install (macOS)"
            echo ""
            echo "1. Download \`${zip_name}\` from this release."
            echo "2. Unzip; move \`Clyde.app\` to \`/Applications\`."
            echo "3. Remove the quarantine attribute (required, app is unsigned):"
            echo ""
            echo '   ```bash'
            echo "   xattr -cr /Applications/Clyde.app"
            echo '   ```'
            echo ""
            echo "   Without this step macOS shows \"Clyde is damaged and can't be opened\"."
            echo "4. Launch normally (double-click)."
            echo ""
            echo "## Checksum"
            echo ""
            echo '```'
            cat "${out_dir}/SHA256SUMS.txt"
            echo '```'
        } > "${notes}"
        echo "Draft notes: ${notes}"
    fi
    echo ""
    echo "=== Packaging done ==="
    du -sh "${out_dir}/${zip_name}"
    echo "Zip:   ${out_dir}/${zip_name}"
    echo "Notes: ${notes}"
    echo ""
    echo "Next: edit RELEASE_NOTES.md, then run 'just release-publish'"

# Release build (build-number bump + build + commit, no tag, no zip)
release-build: release-guard bump-build build-mac commit-bump

# Release patch (1.0.0 → 1.0.1): bump + build + commit + tag + package
release-patch: release-guard (bump-version "patch") build-mac tag package-release

# Release minor (1.0.0 → 1.1.0)
release-minor: release-guard (bump-version "minor") build-mac tag package-release

# Release major (1.0.0 → 2.0.0)
release-major: release-guard (bump-version "major") build-mac tag package-release

# Publish: commit release notes/sha, push, create GitHub Release with zip asset
release-publish:
    #!/usr/bin/env bash
    set -euo pipefail
    ver=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    tag="v${ver%%+*}"
    out_dir="{{release_dir}}/${tag}"
    zip_path="${out_dir}/Clyde-${tag}-macos.zip"
    notes="${out_dir}/RELEASE_NOTES.md"
    if [ ! -f "${zip_path}" ] || [ ! -f "${notes}" ]; then
        echo "ERROR: missing artifacts in ${out_dir}. Run a release-* recipe first."
        exit 1
    fi
    if ! git rev-parse "${tag}" >/dev/null 2>&1; then
        echo "ERROR: git tag ${tag} not found."
        exit 1
    fi
    echo "Committing release metadata..."
    git add "${out_dir}/SHA256SUMS.txt" "${notes}"
    if [ -f "{{release_dir}}/README.md" ]; then
        git add "{{release_dir}}/README.md"
    fi
    if ! git diff --cached --quiet; then
        git commit -m "release: notes and checksum for ${tag}"
    else
        echo "No metadata changes to commit."
    fi
    echo "Pushing main + tag (atomic)..."
    git push origin main "${tag}"
    echo "Creating GitHub Release ${tag}..."
    if gh release view "${tag}" >/dev/null 2>&1; then
        echo "Release ${tag} already exists; uploading asset (clobber)."
        gh release upload "${tag}" "${zip_path}" --clobber
    else
        gh release create "${tag}" \
            --title "Clyde ${tag}" \
            --notes-file "${notes}" \
            "${zip_path}"
    fi
    echo ""
    echo "=== Published ${tag} ==="

# Push commits + all tags (no release creation)
release-push:
    git push origin main --follow-tags

# ==============================================================================
# CODE GENERATION
# ==============================================================================

# Run build_runner once
gen:
    {{dart}} run build_runner build --delete-conflicting-outputs

# Watch mode — auto-regenerate on changes
gen-watch:
    {{dart}} run build_runner watch --delete-conflicting-outputs

# Regenerate Locales (locale_keys.g.dart + locales.g.dart from JSON)
gen-l10n:
    {{dart}} run {{l10n_tool}}

# Generate everything (build_runner + l10n)
gen-all: gen gen-l10n

# Clean build_runner cache and regenerate
gen-clean:
    {{dart}} run build_runner clean
    just gen

# ==============================================================================
# PROJECT MAINTENANCE
# ==============================================================================

# Get dependencies
get:
    {{flutter}} pub get

# Upgrade dependencies (respects pubspec constraints)
upgrade:
    {{flutter}} pub upgrade

# Upgrade to latest major versions
upgrade-major:
    {{flutter}} pub upgrade --major-versions

# Show outdated packages
outdated:
    {{flutter}} pub outdated

# Clean build artifacts
clean:
    {{flutter}} clean

# Deep clean — flutter clean + drop generated dart files + pub get
clean-deep:
    {{flutter}} clean
    rm -rf .dart_tool/build
    find lib -name "*.g.dart" -type f -delete
    find lib -name "*.freezed.dart" -type f -delete
    find lib -name "*.config.dart" -type f -delete
    just get

# ==============================================================================
# CODE QUALITY
# ==============================================================================

# Static analysis
analyze:
    {{dart}} analyze

# Verbose analysis (don't fail on info/warning)
analyze-verbose:
    {{dart}} analyze --no-fatal-infos --no-fatal-warnings

# Format check (dry run, excludes generated)
format-check:
    find lib test -name '*.dart' \
        ! -name '*.g.dart' \
        ! -name '*.freezed.dart' \
        ! -name '*.config.dart' \
        ! -name '*.gr.dart' \
        ! -name 'locale_keys.g.dart' \
        ! -name 'locales.g.dart' \
        -print0 | xargs -0 {{dart}} format -l 120 --set-exit-if-changed --output=none

# Format (excludes generated)
format:
    find lib test -name '*.dart' \
        ! -name '*.g.dart' \
        ! -name '*.freezed.dart' \
        ! -name '*.config.dart' \
        ! -name '*.gr.dart' \
        ! -name 'locale_keys.g.dart' \
        ! -name 'locales.g.dart' \
        -print0 | xargs -0 {{dart}} format -l 120

# Apply dart fix
fix:
    {{dart}} fix --apply

# Dry-run dart fix
fix-dry:
    {{dart}} fix --dry-run

# All quality checks (CI-friendly)
check: analyze format-check
    @echo "All quality checks passed"

# ==============================================================================
# TESTING
# ==============================================================================

# Run tests
test *args:
    {{flutter}} test {{args}}

# Tests with coverage
test-coverage:
    {{flutter}} test --coverage

# Run a specific file
test-file file:
    {{flutter}} test {{file}}

# ==============================================================================
# GIT WORKFLOWS
# ==============================================================================

# Branch + status + last 5 commits
git-status:
    @echo "=== Branch Info ==="
    @git branch -vv
    @echo ""
    @echo "=== Status ==="
    @git status -sb
    @echo ""
    @echo "=== Recent Commits (last 5) ==="
    @git log --oneline -5

# Sync with remote (fetch + pull --rebase)
git-sync:
    git fetch --all --prune
    git pull --rebase

# Diff summary
git-diff:
    @git diff --stat

# Stage all + commit
commit message:
    git add -A
    git commit -m "{{message}}"

# Stage specific files + commit
commit-files message +files:
    git add {{files}}
    git commit -m "{{message}}"

# Amend last commit (keep message)
commit-amend:
    git add -A
    git commit --amend --no-edit

# Push current branch
push:
    git push

# Push new branch with upstream tracking
push-new:
    git push -u origin HEAD

# Force push with lease
push-force:
    git push --force-with-lease

# stage + commit + push (one-shot)
save message:
    git add -A
    git commit -m "{{message}}"
    git push

# Create + switch to new branch
branch name:
    git switch -c {{name}}

# Switch to existing branch
switch branch:
    git switch {{branch}}

# Delete merged branches (dry list, then prune)
branch-cleanup:
    @echo "=== Merged branches (will delete) ==="
    @git branch --merged main | grep -v "^\*\|main\|master" || echo "Nothing merged"
    git branch --merged main | grep -v "^\*\|main\|master" | xargs -r git branch -d

# Merge branch into current (no-ff)
merge branch:
    git merge --no-ff {{branch}}

# Rebase current onto main
rebase-main:
    git fetch origin main
    git rebase origin/main

# ==============================================================================
# AI-OPTIMIZED SEARCH
# ==============================================================================

# Search dart files (excludes generated)
search pattern:
    @grep -rn --include="*.dart" --exclude="*.g.dart" --exclude="*.freezed.dart" --exclude="*.config.dart" "{{pattern}}" {{lib_path}} | head -50

# Search inside a feature
search-feature feature pattern:
    @grep -rn --include="*.dart" "{{pattern}}" "{{features_path}}/{{feature}}" | head -50

# Find TODO / FIXME / HACK / XXX
todos:
    @grep -rn --include="*.dart" --exclude="*.g.dart" -E "TODO|FIXME|HACK|XXX" {{lib_path}} | head -50

# Recently modified dart files (default last 7 days)
recent days="7":
    @find {{lib_path}} -name "*.dart" -mtime -{{days}} -not -name "*.g.dart" -not -name "*.freezed.dart" -not -name "*.config.dart" | sort

# Files with > N lines (default 300)
large-files lines="300":
    @find {{lib_path}} -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -not -name "*.config.dart" -exec wc -l {} \; | awk '$1 > {{lines}} {print}' | sort -rn | head -30

# All cubits
cubits:
    @grep -rn --include="*.dart" -E "class .+Cubit extends" {{lib_path}} | head -50

# All features (top-level)
features:
    @ls -1 {{features_path}}

# Imports of a package
imports package:
    @grep -rn --include="*.dart" --exclude="*.g.dart" "import.*{{package}}" {{lib_path}} | head -50

# Lines of code (excludes generated)
loc:
    @find {{lib_path}} -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -not -name "*.config.dart" -exec cat {} \; | wc -l | xargs echo "LoC:"

# ==============================================================================
# COMPOSITES
# ==============================================================================

# Fresh project setup
setup: get gen gen-l10n
    @echo "Setup complete"

# Rebuild from scratch (no flutter clean)
rebuild: get gen gen-l10n
    @echo "Rebuild complete"

# Deep rebuild (flutter clean too)
rebuild-deep: clean-deep gen gen-l10n
    @echo "Deep rebuild complete"

# CI pipeline
ci: analyze format-check test
    @echo "CI passed"

# Pre-commit quick validation
pre-commit: analyze format-check
    @echo "Pre-commit passed"

# ==============================================================================
# SHORTCUTS
# ==============================================================================

g: gen
r: run
a: analyze
f: format
t: test
s pattern: (search pattern)
c message: (commit message)
p: push
