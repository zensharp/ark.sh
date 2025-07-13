#!/usr/bin/env bash

set -u

# Functions
function elapsed()
{
	TIMESTAMP="$1"
	
	# Convert input to epoch seconds
	INPUT_EPOCH=$(date --date="$TIMESTAMP" +%s)
	NOW_EPOCH=$(date +%s)

	# Calculate difference in seconds
	delta=$((NOW_EPOCH - INPUT_EPOCH))

	# Convert to human-readable format
	if (( delta < 60 )); then
		echo "$delta seconds ago"
	elif (( delta < 3600 )); then
		mins=$((delta / 60))
		echo "$mins minute(s) ago"
	elif (( delta < 86400 )); then
		hours=$((delta / 3600))
		echo "$hours hour(s) ago"
	else
		days=$((delta / 86400))
		echo "$days day(s) ago"
	fi
}

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
	
	ELAPSED=$(elapsed "$TIMESTAMP")
	echo "v$VERSION was uploaded $ELAPSED from $BRANCH"
fi
