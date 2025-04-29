#!/bin/bash

LOGFILE="$HOME/picframe-master/sync.log"
SLIDESHOW_FOLDER="$HOME/picframe-master/slideshow"
RESCAN_FILE="$SLIDESHOW_FOLDER/.rescan_trigger"

# Example rclone command (adjust as needed):
rclone sync "picfraame" "$SLIDESHOW_FOLDER" --log-file="$LOGFILE" --log-level INFO

# Simulate sync for demonstration purposes:
echo "Starting sync from: picframe" >> "$LOGFILE"
touch "$RESCAN_FILE"
echo "Rescan trigger created: $RESCAN_FILE" >> "$LOGFILE"
