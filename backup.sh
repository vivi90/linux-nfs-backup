#!/bin/bash

# NFS backup script.
# v1.1.1
# 2020 by Vivien Richter <vivien-richter@outlook.de>
# MIT License
# Git repository: https://github.com/vivi90/linux-nfs-backup.git

# Configuration
BACKUP_NFS_TARGET="backup:/mnt/HD_a2/$(cat /proc/sys/kernel/hostname)"
BACKUP_MOUNT_TARGET="/run/media/$USER/backup"
BACKUP_SOURCE="/home/$USER"
BACKUP_NAME="$(basename "$BACKUP_SOURCE")_$(date --iso-8601=seconds)"
BACKUP_KEY_FILE="/home/backup_key_$USER.txt"

# Mount NFS file system and ensure it's finally unmount
sudo mkdir -p $BACKUP_MOUNT_TARGET
sudo mount $BACKUP_NFS_TARGET $BACKUP_MOUNT_TARGET
trap 'sudo umount "$BACKUP_MOUNT_TARGET" && sudo rmdir "$BACKUP_MOUNT_TARGET"' EXIT

# Check available space
SPACE_AVAILABLE="$(df "$BACKUP_MOUNT_TARGET" | awk 'NR == 2 {print $4}')"
SPACE_REQUIRED="$(du -s "$BACKUP_SOURCE" | awk '{print $1}')"
if [[ "$SPACE_AVAILABLE" -ge "$SPACE_REQUIRED" ]];
then
    # Running backup
    BACKUP_KEY="$(sudo cat $BACKUP_KEY_FILE)"
    dar -c "$BACKUP_MOUNT_TARGET/$BACKUP_NAME" -R "$BACKUP_SOURCE" -Kcamellia:"$BACKUP_KEY" -zgzip:9 &
    BACKUP_PID=$!
    while kill -0 "$BACKUP_PID" 2> /dev/null ; do
        BACKUP_BYTES_WRITTEN="0$(du -s "$BACKUP_MOUNT_TARGET/$BACKUP_NAME.1.dar" 2> /dev/null | awk '{print $1}')"
        BACKUP_PROGRESS="$((10#$BACKUP_BYTES_WRITTEN*100/$SPACE_REQUIRED))"
        printf "Progress: $BACKUP_PROGRESS%%\r"
    done
    # Check backup integrity
    dar -t "$BACKUP_MOUNT_TARGET/$BACKUP_NAME" -Kcamellia:"$BACKUP_KEY"
else
    echo "Not enough space. Needs at least $SPACE_REQUIRED KB." > /dev/stderr
    exit 1
fi

# Done
echo "Done."
exit 0
