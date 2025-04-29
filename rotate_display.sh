#!/bin/bash

echo "🔄 Configure display rotation"

echo "Please choose the rotation angle:"
echo "0) 0 degrees (normal)"
echo "1) 90 degrees (right)"
echo "2) 180 degrees (upside down)"
echo "3) 270 degrees (left)"
read -p "Choice [0-3]: " ROTATION_CHOICE

case "$ROTATION_CHOICE" in
  0)
    ROTATE_VALUE=0
    ;;
  1)
    ROTATE_VALUE=1
    ;;
  2)
    ROTATE_VALUE=2
    ;;
  3)
    ROTATE_VALUE=3
    ;;
  *)
    echo "❗ Invalid choice. No changes made."
    exit 1
    ;;
esac

CONFIG_FILE="/boot/config.txt"

# Backup the original config.txt
sudo cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Remove old rotation settings if they exist
sudo sed -i '/^lcd_rotate=/d' "$CONFIG_FILE"
sudo sed -i '/^display_lcd_rotate=/d' "$CONFIG_FILE"

# Add new rotation setting
echo "" | sudo tee -a "$CONFIG_FILE"
echo "# Added by Picframe setup: Rotate display" | sudo tee -a "$CONFIG_FILE"
echo "display_lcd_rotate=$ROTATE_VALUE" | sudo tee -a "$CONFIG_FILE"

echo "✅ Display rotation set to $((ROTATION_CHOICE * 90)) degrees."
echo "ℹ️ Please reboot to apply the changes: sudo reboot"
