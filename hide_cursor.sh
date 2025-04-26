#!/bin/bash

# Erzeuge einen unsichtbaren 1x1 Pixel Cursor dynamisch
CURSOR_FILE="$HOME/.invisible_cursor.xbm"

echo "#define invisible_width 1" > "$CURSOR_FILE"
echo "#define invisible_height 1" >> "$CURSOR_FILE"
echo "static unsigned char invisible_bits[] = { 0x00 };" >> "$CURSOR_FILE"

# Setze den unsichtbaren Cursor
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -cursor "$CURSOR_FILE" "$CURSOR_FILE"
else
    echo "⚠️ xsetroot not found, cursor will not be hidden."
fi
