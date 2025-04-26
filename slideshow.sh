#!/bin/bash

FOLDER="$HOME/slideshow"
CONFIG="$HOME/.slideshow_config"
LOGFILE="$HOME/slideshow.log"
RESCAN_FILE="$FOLDER/.rescan_trigger"

xset -dpms
xset s off
xset s noblank

echo "===== Slideshow started: $(date) =====" >> "$LOGFILE"

IMAGE_EXTENSIONS="jpg jpeg png gif bmp webp"
VIDEO_EXTENSIONS="mp4 mov avi mkv webm"

while true; do
  mapfile -t FILES < <(
    find "$FOLDER" -type f \( \
      -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
      -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o \
      -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.webm" \
    \) -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-
  )

  echo "$(date) - Found files: ${#FILES[@]}" >> "$LOGFILE"

  for FILE in "${FILES[@]}"; do
    EXT="${FILE##*.}"
    EXT="${EXT,,}"

    if [[ " $IMAGE_EXTENSIONS " == *" $EXT "* ]]; then
      DELAY=$(cat "$CONFIG" 2>/dev/null || echo 5)
      echo "$(date) - Showing Pciture: $FILE (for $DELAY seconfd)" >> "$LOGFILE"
      feh --fullscreen --auto-zoom --hide-pointer --quiet "$FILE" 2> >(grep -v "Window Manager does not support MWM hints" >> "$LOGFILE") &
      FEH_PID=$!
      sleep "$DELAY"
      kill "$FEH_PID" 2>/dev/null

    elif [[ " $VIDEO_EXTENSIONS " == *" $EXT "* ]]; then
      echo "$(date) - Starting Video: $FILE" >> "$LOGFILE"
      mpv --vo=x11 --no-audio --fs --no-border --really-quiet --loop=once "$FILE" >> "$LOGFILE" 2>&1
    fi

    if [ -f "$RESCAN_FILE" ]; then
      echo "$(date) - Rescan-Trigger detected – reload" >> "$LOGFILE"
      rm -f "$RESCAN_FILE"
      break
    fi

    tail -n 1000 "$LOGFILE" > "${LOGFILE}.tmp" && mv "${LOGFILE}.tmp" "$LOGFILE"
  done
done
