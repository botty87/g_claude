#!/bin/bash
# Truncate unused Material Symbols font variants (Rounded, Sharp).
# We only use Outlined (default Symbols.X). The package ships all 3.
# Tree-shake doesn't subset variable font axes so --no-tree-shake-icons
# is required for fill: 1 to render — this script reclaims ~23MB.
set -euo pipefail

APP_PATH="${1:?usage: strip_unused_symbol_fonts.sh <path-to-Clyde.app>}"
ASSETS="$APP_PATH/Contents/Frameworks/App.framework/Resources/flutter_assets/packages/material_symbols_icons/lib/fonts"

for variant in MaterialSymbolsRounded.ttf MaterialSymbolsSharp.ttf; do
  if [ -f "$ASSETS/$variant" ]; then
    : > "$ASSETS/$variant"
    echo "  truncated $variant"
  fi
done
