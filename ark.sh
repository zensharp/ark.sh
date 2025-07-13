#!/usr/bin/env bash

set -u

# Program
USERNAME=$1
GAME=$2
CHANNEL=$3
ITCH_IDENTITY="/home/deck/.itch/$USERNAME.env"
ITCH_TARGET="$USERNAME/$GAME:$CHANNEL"
DEST_DIR="$HOME/ark/$USERNAME/$GAME/$CHANNEL"

# Sync build
rm -r $DEST_DIR > /dev/null 2>&1 || true
/home/deck/.local/bin/butler fetch -i "$ITCH_IDENTITY" "$ITCH_TARGET" "$DEST_DIR"

# Set permissions
chmod +x $DEST_DIR/*.exe > /dev/null 2>&1 || true
chmod +x $DEST_DIR/*.application > /dev/null 2>&1 || true

if [[ -f "$DEST_DIR/version.txt" ]]; then
	VERSION=$(awk -F '=' '$1 ~ /^\s*version\s*$/ { gsub(/^ +| +$/, "", $2); print $2 }' $DEST_DIR/version.txt)
	TIMESTAMP=$(awk -F '=' '$1 ~ /^\s*timestamp\s*$/ { gsub(/^ +| +$/, "", $2); print $2 }' $DEST_DIR/version.txt)
	BRANCH=$(awk -F '=' '$1 ~ /^\s*branch\s*$/ { gsub(/^ +| +$/, "", $2); print $2 }' $DEST_DIR/version.txt)
	
	# Convert input to epoch seconds
	INPUT_EPOCH=$(date --date="$TIMESTAMP" +%s)
	NOW_EPOCH=$(date +%s)
	# Calculate difference in seconds
	DELTA=$((NOW_EPOCH - INPUT_EPOCH))
	# Convert to human-readable format
	if (( DELTA < 60 )); then
		ELAPSED="$DELTA seconds ago"
	elif (( DELTA < 3600 )); then
		MINS=$((DELTA / 60))
		ELAPSED="$MINS minute(s) ago"
	elif (( DELTA < 86400 )); then
		HOURS=$((DELTA / 3600))
		ELAPSED="$HOURS hour(s) ago"
	else
		DAYS=$((DELTA / 86400))
		ELAPSED="$DAYS day(s) ago"
	fi
	echo "v$VERSION was uploaded $ELAPSED from $BRANCH"
fi
