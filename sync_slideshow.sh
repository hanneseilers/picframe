#!/bin/bash

LOGFILE="$HOME/picframe-master/sync.log"
SLIDESHOW_FOLDER="$HOME/picframe-master/slideshow"
RESCAN_FILE="$SLIDESHOW_FOLDER/.rescan_trigger"
REMOTE_PATH_FILE="$HOME/picframe-master/.sync_remote"

if [ ! -f "$REMOTE_PATH_FILE" ]; then
  echo "Error: Remote path not defined. Please create the file $REMOTE_PATH_FILE." >> "$LOGFILE"
  exit 1
fi

REMOTE_PATH=$(cat "$REMOTE_PATH_FILE")

# Example rclone command (adjust as needed):
rclone sync "$REMOTE_PATH" "$SLIDESHOW_FOLDER" --log-file="$LOGFILE" --log-level INFO

# Simulate sync for demonstration purposes:
echo "Starting sync from: $REMOTE_PATH" >> "$LOGFILE"
touch "$RESCAN_FILE"
echo "Rescan trigger created: $RESCAN_FILE" >> "$LOGFILE"
