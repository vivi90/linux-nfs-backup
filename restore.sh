#!/bin/bash

# NFS restore script.
# v1.0.1
# 2020 by Vivien Richter <vivien-richter@outlook.de>
# MIT License
# Git repository: https://github.com/vivi90/linux-nfs-backup.git

# Configuration
BACKUP_NFS_SOURCE="backup:/mnt/HD_a2/$(cat /proc/sys/kernel/hostname)"
BACKUP_MOUNT_TARGET="/run/media/$USER/backup"
BACKUP_NAME_PATTERN="$(basename "$BACKUP_SOURCE")_*.tar.gz.gpg"
BACKUP_KEY_FILE="/home/backup_key_$USER.txt"

# Mount NFS file system and ensure it's finally unmount
sudo mkdir $BACKUP_MOUNT_TARGET
sudo mount $BACKUP_NFS_SOURCE $BACKUP_MOUNT_TARGET
trap 'sudo umount "$BACKUP_MOUNT_TARGET" && sudo rmdir "$BACKUP_MOUNT_TARGET"' EXIT

# Search for existing backups
BACKUPS=($(ls /run/media/$USER/backup | grep ".*_.*.1.dar"))
BACKUPS_COUNT=${#BACKUPS[@]}
for ((i = 0; i != BACKUPS_COUNT; i++)); do
   echo "$i: '${BACKUPS[i]}'"
done
read -p "$BACKUPS_COUNT backups found. Please select one to restore: " BACKUP_SELECTED

# Prepare restore destination
read -p "Please enter target: " RESTORE_TARGET
sudo mkdir -p "$RESTORE_TARGET"

# Check available space and running restore
SPACE_AVAILABLE="$(df "$RESTORE_TARGET" | awk 'NR == 2 {print $4}')"
SPACE_REQUIRED="$(du -s "$BACKUP_MOUNT_TARGET/${BACKUPS[$BACKUP_SELECTED]}" | awk '{print $1}')"
if [[ "$SPACE_AVAILABLE" -ge "$SPACE_REQUIRED" ]];
then
    sudo dar -x "$BACKUP_MOUNT_TARGET/$(echo ${BACKUPS[$BACKUP_SELECTED]} | cut -d '.' -f 1)" -R "$RESTORE_TARGET" -Kcamellia:"$(sudo cat $BACKUP_KEY_FILE)"
else
    echo "Not enough space. Needs at least $SPACE_REQUIRED KB." > /dev/stderr
    exit 1
fi

# Done
echo "Done."
exit 0
