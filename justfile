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

# Build macOS release app + strip unused Symbol font variants (~27MB saved)
build-mac:
    {{flutter}} build macos --release --no-tree-shake-icons
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

# Bump build number only (e.g. 1.0.0+1 → 1.0.0+2)
[private]
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

# Commit version bump and create git tag (vX.Y.Z)
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

# Release build with build-number bump (no tag)
release-build: bump-build build-mac

# Release patch (1.0.0 → 1.0.1) + build + tag
release-patch: (bump-version "patch") build-mac tag

# Release minor (1.0.0 → 1.1.0) + build + tag
release-minor: (bump-version "minor") build-mac tag

# Release major (1.0.0 → 2.0.0) + build + tag
release-major: (bump-version "major") build-mac tag

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
