#!/usr/bin/env bash
# xmonad-update.sh
# Updates stack, xmonad, and xmonad-contrib to latest versions.

set -euo pipefail

STACK_YAML="$HOME/.stack/global-project/stack.yaml"

echo "==> Checking current versions..."
CURRENT_XMONAD=$(xmonad --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
CURRENT_STACK=$(stack --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
echo "    stack:   $CURRENT_STACK"
echo "    xmonad:  $CURRENT_XMONAD"

# ============================================================
# 1. Update stack itself
# ============================================================
echo ""
echo "==> Upgrading stack..."
stack upgrade

# Copy to /usr/bin if on a different device
if ! diff -q "$HOME/.local/bin/stack" /usr/bin/stack &>/dev/null; then
    echo "==> Copying stack to /usr/bin (requires sudo)..."
    sudo cp "$HOME/.local/bin/stack" /usr/bin/stack
fi

NEW_STACK=$(stack --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
echo "    stack: $CURRENT_STACK -> $NEW_STACK"

# ============================================================
# 2. Fetch latest xmonad + xmonad-contrib versions from Hackage
# ============================================================
echo ""
echo "==> Fetching latest xmonad versions from Hackage..."

LATEST_XMONAD=$(curl -s "https://hackage.haskell.org/package/xmonad" \
    | grep -oP 'xmonad-\K\d+\.\d+\.\d+' | sort -V | tail -1)

LATEST_CONTRIB=$(curl -s "https://hackage.haskell.org/package/xmonad-contrib" \
    | grep -oP 'xmonad-contrib-\K\d+\.\d+\.\d+' | sort -V | tail -1)

if [[ -z "$LATEST_XMONAD" || -z "$LATEST_CONTRIB" ]]; then
    echo "ERROR: Couldn't fetch latest versions from Hackage. Check your connection."
    exit 1
fi

echo "    Latest xmonad:         $LATEST_XMONAD"
echo "    Latest xmonad-contrib: $LATEST_CONTRIB"

# ============================================================
# 3. Update stack.yaml extra-deps
# ============================================================
echo ""
echo "==> Updating $STACK_YAML..."

TMPFILE=$(mktemp)
grep -v '^\s*- xmonad-\|^\s*- xmonad-contrib-' "$STACK_YAML" > "$TMPFILE"

if ! grep -q '^extra-deps:' "$TMPFILE"; then
    echo "" >> "$TMPFILE"
    echo "extra-deps:" >> "$TMPFILE"
fi

echo "  - xmonad-${LATEST_XMONAD}" >> "$TMPFILE"
echo "  - xmonad-contrib-${LATEST_CONTRIB}" >> "$TMPFILE"

cp "$TMPFILE" "$STACK_YAML"
rm "$TMPFILE"

echo "    extra-deps updated."

# ============================================================
# 4. Rebuild
# ============================================================
echo ""
echo "==> Installing xmonad $LATEST_XMONAD and xmonad-contrib $LATEST_CONTRIB..."
stack install xmonad xmonad-contrib

NEW_XMONAD=$(xmonad --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || echo "unknown")

# ============================================================
# 5. Summary
# ============================================================
echo ""
echo "==> Done."
echo "    stack:   $CURRENT_STACK -> $NEW_STACK"
echo "    xmonad:  $CURRENT_XMONAD -> $NEW_XMONAD"
echo ""
echo "Recompile your config with: xmonad --recompile && xmonad --restart"
