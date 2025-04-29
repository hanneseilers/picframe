
#!/bin/bash
set -e

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y python3-flask feh mpv xinit x11-xserver-utils unclutter dnsmasq hostapd network-manager rclone

echo "🔧 Setting up X11 autostart with unclutter..."
cat > "$HOME/.xinitrc" << 'EOF'
#!/bin/bash
xset s off
xset -dpms
xset s noblank
~/picframe-master/hide_cursor.sh
unclutter -idle 0 -root &
xinput disable "$(xinput list | grep -i 'FT5406' | awk -F'id=' '{print $2}' | awk '{print $1}')" 2>/dev/null
~/picframe-master/slideshow.sh
EOF
chmod +x "$HOME/.xinitrc"

echo "🛠 Configuring autologin..."

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

echo "⚙️ Setting up systemd service for Flask web server..."
cat << EOF | sudo tee /etc/systemd/system/flask-web.service > /dev/null
[Unit]
Description=Flask Webinterface for Slideshow
After=network.target

[Service]
User=$USER
WorkingDirectory=/home/$USER/picframe-master/slideshow-web
Environment="FLASK_APP=/home/$USER/picframe-master/slideshow-web/app.py"
ExecStart=/usr/bin/flask run --host=0.0.0.0 --port=5000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

SUDOERS_FILE="/etc/sudoers.d/${USER_NAME}-nmcli"
echo "➕ Creating sudoers-file: $SUDOERS_FILE"
sudo cat << EOF | sudo tee "$SUDOERS_FILE" > /dev/null
${USER_NAME} ALL=(ALL) NOPASSWD: /usr/bin/nmcli, /sbin/reboot
EOF
sudo chmod 0440 "$SUDOERS_FILE"

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable flask-web.service

echo "🔧 Setting up .bash_profile to autostart X..."
cat > "$HOME/.bash_profile" << 'EOF'
if [ -z "$SSH_CONNECTION" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
EOF

echo "⚙️ Setting up Wi-Fi fallback check service..."
cat << 'EOF' | sudo tee /usr/local/bin/wifi_check.sh > /dev/null
#!/bin/bash
echo "[wifi_check] Checking Wi-Fi connection..."
WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi" | cut -d: -f1 | head -n1)

if [ -z "$WIFI_DEVICE" ]; then
    echo "[wifi_check] No Wi-Fi device found."
    exit 1
fi

IS_WIFI_CONNECTED=$(nmcli -t -f DEVICE,STATE device | grep "^${WIFI_DEVICE}:connected" || true)

if [ -n "$IS_WIFI_CONNECTED" ]; then
    echo "[wifi_check] Wi-Fi is connected."
else
    echo "[wifi_check] No Wi-Fi connection. Activating hotspot..."
    sudo nmcli radio wifi on
    sudo nmcli connection up picframe
    sudo systemctl restart dnsmasq
    sudo systemctl restart hostapd
fi
EOF
sudo chmod +x /usr/local/bin/wifi_check.sh

echo "   writing hotspot configuration..."
cat << 'EOF' | sudo tee /etc/hostapd/hostapd.conf > /dev/null
interface=wlan0
ssid=picframe
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wmm_enabled=1
wpa=0
EOF

cat << 'EOF' | sudo tee /etc/dnsmasq.conf > /dev/null
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
address=/#/192.168.4.1
EOF

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

echo "   creating wifi check service ..."
cat << 'EOF' | sudo tee /etc/systemd/system/wifi-check.service > /dev/null
[Unit]
Description=WiFi Check and Hotspot Activation
After=network-online.target NetworkManager-wait-online.service
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/wifi_check.sh
Type=oneshot
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable wifi-check.service

echo "▶️ Running hide_cursor.sh..."
chmod +x "$HOME/picframe-master/hide_cursor.sh"
chmod +x "$HOME/picframe-master/reset_cursor.sh"
# "$HOME/picframe-master/hide_cursor.sh"

echo "🌐 Setting up rclone remote 'picframe'..."
if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
  echo "No existing rclone config found."
fi

echo ""
echo "Which cloud service do you want to configure?"
echo "1) Nextcloud/Owncloud (via WebDAV)"
echo "2) Dropbox"
echo "3) Manual setup (rclone config)"
read -p "Choice [1-3]: " CLOUD_CHOICE

if [ "$CLOUD_CHOICE" = "1" ]; then
  while true; do
    read -p "🔗 Enter your Nextcloud server URL (e.g. https://cloud.example.com/remote.php/webdav): " NEXTCLOUD_URL
    if [[ "$NEXTCLOUD_URL" == https://* ]]; then
      break
    else
      echo "❗ Please enter a valid URL starting with https://"
    fi
  done

  while true; do
    read -p "👤 Enter username: " NEXTCLOUD_USER
    if [ -n "$NEXTCLOUD_USER" ]; then
      break
    else
      echo "❗ Username cannot be empty."
    fi
  done

  while true; do
    read -s -p "🔒 Enter password: " NEXTCLOUD_PASS
    echo
    if [ -n "$NEXTCLOUD_PASS" ]; then
      break
    else
      echo "❗ Password cannot be empty."
    fi
  done

  rclone config create picframe webdav url="$NEXTCLOUD_URL" vendor=nextcloud user="$NEXTCLOUD_USER" pass="$NEXTCLOUD_PASS"
elif [ "$CLOUD_CHOICE" = "2" ]; then
  echo "🌐 Starting Dropbox OAuth setup..."
  rclone config create picframe dropbox
else
  echo "🔧 Manual rclone config..."
  rclone config
fi

echo "📂 Listing contents of remote 'picframe' to verify connection..."
rclone lsd picframe:

echo ""
echo "🗂 Please enter the path inside the remote 'picframe' to sync (leave empty for root folder):"
read REMOTE_PATH

if [ -z "$REMOTE_PATH" ]; then
  echo "picframe:" > "$HOME/.sync_remote"
else
  echo "picframe:$REMOTE_PATH" > "$HOME/picframe-master/.sync_remote"
fi

echo "▶️ Running initial sync..."
mkdir "$HOME/picframe-master/slideshow"
chmod +x "$HOME/picframe-master/sync_slideshow.sh"
bash "$HOME/picframe-master/sync_slideshow.sh"

chmod +x "$HOME/picframe-master/slideshow.sh"
echo "✅ Setup complete. Please reboot: sudo reboot"
