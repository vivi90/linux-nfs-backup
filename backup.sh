#!/bin/bash

# NFS backup script.
# v1.0.0
# 2020 by Vivien Richter <vivien-richter@outlook.de>
# MIT License
# Git repository: https://github.com/vivi90/linux-nfs-backup.git

# Configuration
BACKUP_NFS_TARGET="backup:/mnt/HD_a2/$(cat /proc/sys/kernel/hostname)"
BACKUP_MOUNT_TARGET="/run/media/$USER/backup"
#BACKUP_SOURCE="/home/$USER"
BACKUP_SOURCE="test"
BACKUP_NAME="$(basename "$BACKUP_SOURCE")_$(date --iso-8601=seconds)"
KEY_FILE="/home/backup_key_$USER.txt"

# Mount NFS file system and ensure it's finally unmount
sudo mkdir $BACKUP_MOUNT_TARGET
sudo mount $BACKUP_NFS_TARGET $BACKUP_MOUNT_TARGET
trap 'sudo umount "$BACKUP_MOUNT_TARGET" && sudo rmdir "$BACKUP_MOUNT_TARGET"' EXIT

# Check available space and running backup
SPACE_AVAILABLE="$(df "$BACKUP_MOUNT_TARGET" | awk 'NR == 2 {print $4}')"
SPACE_REQUIRED="$(du -s "$BACKUP_SOURCE" | awk '{print $1}')"
if [[ "$SPACE_AVAILABLE" -ge "$SPACE_REQUIRED" ]];
then
    dar -c "$BACKUP_MOUNT_TARGET/$BACKUP_NAME" -R "$BACKUP_SOURCE" -Kcamellia:"$(sudo cat $KEY_FILE)" -zxz:9
else
    echo "Not enough space. Needs at least $SPACE_REQUIRED KB." > /dev/stderr
    exit 1
fi

# Done
exit 0
