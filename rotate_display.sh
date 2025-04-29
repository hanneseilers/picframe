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

# Define paths
XINITRC="$HOME/.xinitrc"
BACKUP="$HOME/.xinitrc.backup"
XRANDR_CMD="xrandr --output $DISPLAY_NAME --rotate $ROTATE"

# Backup .xinitrc if it exists
if [ -f "$XINITRC" ]; then
  cp "$XINITRC" "$BACKUP"
  echo "Backup of existing .xinitrc saved to $BACKUP"
fi

# Prepare new .xinitrc
{
  if grep -q '^#!' "$XINITRC" 2>/dev/null; then
    # Preserve shebang line
    head -n1 "$XINITRC"
    echo "$XRANDR_CMD"
    # Remove previous identical xrandr lines and shebang from the rest
    tail -n +2 "$XINITRC" | grep -vF "$XRANDR_CMD"
  else
    # No shebang found – just insert xrandr at the top
    echo '#!/bin/bash'
    echo "$XRANDR_CMD"
    cat "$XINITRC" 2>/dev/null | grep -vF "$XRANDR_CMD"
  fi
} > "$XINITRC.new"

mv "$XINITRC.new" "$XINITRC"
chmod +x "$XINITRC"

echo "Applying rotation now..."
eval "DISPLAY=:0 $XRANDR_CMD"

echo "✅ Display rotation set to $(((ROTATION_CHOICE-1) * 90)) degrees."
echo "ℹ️ Please reboot to permanently apply the changes: sudo reboot"
