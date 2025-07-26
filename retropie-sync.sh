#!/bin/bash

# === RetroPie Sync Script ===
# This script synchronizes saves, savestates, ROMs, and media files between your RetroPie system and a NAS.
# It uses rsync over SSH and performs bidirectional syncs (NAS → Pi, then Pi → NAS).
# Before running: edit the configuration section below to match your setup.

echo "Starting RetroPie sync script..."

# ===============================
# USER CONFIGURATION SECTION
# ===============================

# IP address of your NAS
NAS_IP="192.168.?.???"

# SSH port used by your NAS (default is 22, change if needed)
SSH_PORT=22

# SSH username for NAS access
NAS_USER="pi"

# Base path to the RetroPie folder on your NAS
# Example: /srv/dev-disk-by-uuid-xxxxxxxx/RetroGames
NAS_BASE_PATH="/srv/dev-disk-by-uuid-xxxxxxxx/RetroGames"

# List of ROM subfolders to EXCLUDE from syncing
EXCLUDED_ROMS=(3ds dos gc nsw ps2 wii)

# List of media subfolders to EXCLUDE from syncing
EXCLUDED_MEDIA=("Nintendo 3DS" "Gamecube" "Playstation 2" "Wii")

# ===============================
# END OF USER CONFIGURATION
# ===============================

# Local RetroPie paths
LOCAL_BASE="/home/pi/RetroPie"
LOCAL_SAVE_PATH="$LOCAL_BASE/saves/"
LOCAL_SAVESTATES_PATH="$LOCAL_BASE/savestates/"
LOCAL_ROMS_PATH="$LOCAL_BASE/roms/"
LOCAL_MEDIA_PATH="$LOCAL_BASE/media/"

# NAS paths
NAS_BASE="$NAS_USER@$NAS_IP:$NAS_BASE_PATH"
NAS_SAVE_PATH="$NAS_BASE/saves/"
NAS_SAVESTATES_PATH="$NAS_BASE/savestates/"
NAS_ROMS_PATH="$NAS_BASE/roms/"
NAS_MEDIA_PATH="$NAS_BASE/media/"

# Build exclusion flags for rsync
build_excludes() {
    local arr=("$@")
    local flags=()
    for folder in "${arr[@]}"; do
        flags+=(--exclude="$folder/")
    done
    echo "${flags[@]}"
}

ROM_EXCLUDE_FLAGS=($(build_excludes "${EXCLUDED_ROMS[@]}"))
MEDIA_EXCLUDE_FLAGS=($(build_excludes "${EXCLUDED_MEDIA[@]}"))

# Check NAS availability
ping -c 1 "$NAS_IP" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "NAS is unreachable at $NAS_IP. Sync aborted."
    sleep 5
    exit 1
fi

# Function to sync a pair of directories
sync_pair() {
    local local_path="$1"
    local remote_path="$2"
    shift 2
    local excludes=("$@")

    echo "Syncing from NAS to Pi: $remote_path → $local_path"
    rsync -avu -e "ssh -p $SSH_PORT" "${excludes[@]}" "$remote_path" "$local_path"

    echo "Syncing from Pi to NAS: $local_path → $remote_path"
    rsync -avu -e "ssh -p $SSH_PORT" "${excludes[@]}" "$local_path" "$remote_path"
}

# === Perform Syncs ===

sync_pair "$LOCAL_SAVE_PATH" "$NAS_SAVE_PATH"
sync_pair "$LOCAL_SAVESTATES_PATH" "$NAS_SAVESTATES_PATH"
sync_pair "$LOCAL_ROMS_PATH" "$NAS_ROMS_PATH" "${ROM_EXCLUDE_FLAGS[@]}"
sync_pair "$LOCAL_MEDIA_PATH" "$NAS_MEDIA_PATH" "${MEDIA_EXCLUDE_FLAGS[@]}"

echo "Sync complete."
sleep 4
