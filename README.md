# 📷 Picframe Setup Guide

Welcome to **Picframe** — a minimalistic photo and video slideshow system for Raspberry Pi!

This guide explains:
- What Picframe does
- How to prepare your Raspberry Pi (Windows/Linux)
- How to install Picframe from GitHub
- How to use the system after installation

---

## 🧠 What does Picframe do?

- Syncs images and videos from a cloud folder (Nextcloud, Dropbox, etc.)
- Displays them automatically in fullscreen on a Raspberry Pi screen
- Supports `.jpg`, `.png`, `.gif`, `.mp4`, `.mov` and more
- Auto-updates the slideshow after new files are synced
- Automatically starts the slideshow at boot
- Automatically disables power-saving and screen blanking
- Fully controlled via minimal and responsive Web UI (Flask server)

---

## 🖥️ Preparing your Raspberry Pi

### On Windows:

1. Download and install [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Flash **Raspberry Pi OS Lite (32-bit)** onto an SD card.
3. Enable SSH:
   - After flashing, create an empty file named `ssh` (without extension) in the boot partition.
4. Insert the SD card into the Pi and boot it up.
5. Find the Pi's IP address in your router or via an app like Fing.

---

### On Linux:

1. Install `rpi-imager` or use `dd` to flash **Raspberry Pi OS Lite** to the SD card.
2. After flashing:
   ```bash
   touch /media/YOUR_USER/boot/ssh
   ```
   *(adjust path if needed)*
3. Insert SD card and boot the Pi.
4. Find the IP address via router interface or:
   ```bash
   nmap -sn 192.168.1.0/24
   ```

---

## 🔌 First SSH Connection

Connect to your Pi:
```bash
ssh pi@<your-pi-ip>
# Default password: raspberry
```

It is recommended to immediately change the password:
```bash
passwd
```

---

## 📥 Download and Install Picframe

1. Install `unzip` if not already installed:
   ```bash
   sudo apt update
   sudo apt install unzip
   ```

2. Download the latest release from GitHub:
   ```bash
   wget https://github.com/hanneseilers/picframe/releases/latest/download/picframe.zip
   ```

3. Unzip the archive:
   ```bash
   unzip picframe.zip
   cd picframe
   ```

4. Make the installer executable:
   ```bash
   chmod +x install_slideshow.sh
   ```

5. Run the installer:
   ```bash
   ./install_slideshow.sh
   ```

During installation, you will:
- Set up cloud connection (Nextcloud, Dropbox, or manual)
- Configure folder to sync
- Automatically set up WiFi fallback Hotspot (optional)
- Automatically disable mouse pointer and screensaver

---

## 🚀 Using Picframe

After rebooting the Pi:

- The slideshow will automatically start
- Images and videos will be displayed in order based on their file dates
- The web server (Flask) is accessible via:
  ```
  http://<your-pi-ip>:5000
  ```

You can:
- Change the slideshow timeout
- Trigger manual cloud syncs
- (Optionally) configure WiFi settings if needed

---

## 🛠️ Additional Commands

- Reset hidden cursor (if needed manually):
  ```bash
  ~/reset_cursor.sh
  ```

- Manually trigger a sync:
  ```bash
  ~/sync_slideshow.sh
  ```

- Restart slideshow (after settings change):
  ```bash
  sudo reboot
  ```

---

## 📚 Troubleshooting

| Problem | Solution |
|:---|:---|
| Slideshow not starting | Check `.xinitrc` and ensure last line is `~/slideshow.sh` |
| No WiFi connection | Hotspot mode should activate automatically |
| Cursor visible again | Run `~/hide_cursor.sh` or reboot |
| Cannot connect to web UI | Check if Flask service is running: `sudo systemctl status flask-web` |

---

## 🙌 Thank you for using Picframe!

Made with ❤️ for clean, simple digital photo frames.
