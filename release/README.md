# Releases

This folder tracks **release metadata** (notes, checksums) for Clyde.

**Binaries are NOT stored here.** The `.app` zip lives as a GitHub Release asset:
[github.com/botty87/g_claude/releases](https://github.com/botty87/g_claude/releases)

`release/**/*.zip` is gitignored. The folder is committed only for release notes
and SHA256 checksums, so the repo stays small while history is preserved.

## Layout

```
release/
├── README.md              ← this file
└── vX.Y.Z/
    ├── RELEASE_NOTES.md   ← human-written notes (auto-draft from git log)
    └── SHA256SUMS.txt     ← checksum of the zipped .app
```

## Workflow

1. `just release-patch` (or `release-minor` / `release-major`)
   → bumps pubspec, builds `.app`, commits, tags, packages zip + draft notes.
2. Edit `release/vX.Y.Z/RELEASE_NOTES.md` to taste.
3. `just release-publish`
   → commits notes + checksum, pushes `main` and tag, creates the GitHub Release
     with the zip attached as asset.

`just bump-build` and `just release-build` cover build-only bumps with no tag.
