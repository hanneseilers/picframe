#!/bin/bash

# Setze den Standardcursor wieder zurück
if command -v xsetroot >/dev/null 2>&1; then
    xsetroot -cursor_name left_ptr
    echo "✅ Cursor reset to default."
else
    echo "⚠️ xsetroot not found, cursor reset skipped."
fi
