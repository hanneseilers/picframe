#!/bin/bash

echo "🔄 Configure display rotation"
echo "Available displays:"
DISPLAY=:0 xrandr --query | grep " connected" | cut -d" " -f1

read -p "Enter the name of the display you want to rotate (e.g., DSI-1, HDMI-1): " DISPLAY_NAME

echo "Choose rotation angle:"
echo "  1) 0   - normal"
echo "  2) 90  - rotate right"
echo "  3) 180 - inverted"
echo "  4) 270 - rotate left"
read -p "Enter rotation angle choise (1, 2, 3, 4): " ROTATION_CHOICE

# Map angle to xrandr rotation
case "$ROTATION_CHOICE" in
  1)
    ROTATE="normal"
    ;;
  2)
    ROTATE="right"
    ;;
  3)
    ROTATE="inverted"
    ;;
  4)
    ROTATE="left"
    ;;
  *)
    echo "❗ Invalid choice. No changes made."
    exit 1
    ;;
esac

# Ensure .xinitrc exists
touch ~/.xinitrc

# Append xrandr command if not already present
XRANDR_CMD="xrandr --output $DISPLAY_NAME --rotate $ROTATE"
if grep -Fxq "$XRANDR_CMD" ~/.xinitrc; then
  echo "The rotation command is already present in .xinitrc."
else
  echo "$XRANDR_CMD" >> ~/.xinitrc
  echo "Added the following line to .xinitrc:"
  echo "$XRANDR_CMD"
fi

DISPLAY=:0 "$XRANDR_CMD"

echo "✅ Display rotation set to $(((ROTATION_CHOICE-1) * 90)) degrees."
echo "ℹ️ Please reboot to apply the changes: sudo reboot"
