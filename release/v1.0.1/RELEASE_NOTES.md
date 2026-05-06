# Clyde v1.0.1

_Released 2026-05-06_

## Changes

- Initial release.

## Install (macOS)

1. Download `Clyde-v1.0.1-macos.zip` from this release.
2. Unzip; move `Clyde.app` to `/Applications`.
3. Remove the quarantine attribute (required, app is unsigned):

   ```bash
   xattr -cr /Applications/Clyde.app
   ```

   Without this step macOS shows "Clyde is damaged and can't be opened".
4. Launch normally (double-click).

## Checksum

```
9f44d3cfe0776533cb600e2c8e0aa8285a551d26705220afa0a8ca156018f7d0  Clyde-v1.0.1-macos.zip
```
