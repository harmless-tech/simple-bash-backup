#!/bin/bash

### Simple Bash Backup by harmless-tech
### Version: 2
### Git: https://github.com/harmless-tech/simple-bash-backup
### License: MIT (https://github.com/harmless-tech/simple-bash-backup/blob/main/LICENSE)

echo "Simple Bash Backup by harmless-tech (v2)"

# Script path
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#

# Time
TIME=`date +%Y-%m-%d-%T`
TIME=${TIME/:/-}
TIME=${TIME/:/-}
#

# Settings
SETTINGS_FILE="$SCRIPT_DIR/settings.env"
#

# Tar
TAR_CACHE_DIR="$SCRIPT_DIR/cache"
TAR_NAME="backup-$TIME.tar.gz"
#

# Settings that should be overriden in 'settings.env'
BACKUP_SRC=
BACKUP_DRIVE_MOUNT_PT=
BACKUP_DRIVE_UUID=
BACKUP_DRIVE_DIR=
#

# Functions
function exit_umount {
  STORE=$?
  umount $BACKUP_DRIVE_MOUNT_PT
  exit $STORE
}
#

echo "Loading settings.env if possible..."
if [ -f $SETTINGS_FILE ]; then
  echo "Loading..."
  source "$SETTINGS_FILE"
fi
echo "Done"

echo "Checking if all settings are set..."
if [[ -z "$BACKUP_SRC" ]]; then
  echo "BACKUP_SRC is unset, this should point to the directory you want to backup."
  exit 1
fi
if [[ -z "$BACKUP_DRIVE_MOUNT_PT" ]]; then
  echo "BACKUP_DRIVE_PT is unset, this should be the directory you want the drive to mount to."
  exit 1
fi
if [[ -z "$BACKUP_DRIVE_UUID" ]]; then
  echo "BACKUP_DRIVE_UUID is unset, this should be the UUID of the drive you want to backup to."
  exit 1
fi
if [[ -z "$BACKUP_DRIVE_DIR" ]]; then
  echo "BACKUP_DRIVE_DIR is unset, this should be the directory to put backup in on the drive."
  exit 1
fi
echo "Done"

echo "Mounting drive..."
# Creates mount point for drive.
if ! mkdir -p $BACKUP_DRIVE_MOUNT_PT; then
  echo "Could not create a mount point at '$BACKUP_DRIVE_MOUNT_PT'."
  exit $?
fi
# Mounts drive with UUID to mount point.
if ! mount "UUID=$BACKUP_DRIVE_UUID" $BACKUP_DRIVE_MOUNT_PT; then
  echo "Could not mount drive '$BACKUP_DRIVE_UUID' at '$BACKUP_DRIVE_MOUNT_PT'."
  exit $?
fi
echo "Done"

echo "Creating backup tar..."
# Creates cache folder.
if ! mkdir -p $TAR_CACHE_DIR; then
  echo "Could not create backup cache directory at '$TAR_CACHE_DIR'."
  exit_umount
fi
# Removes old backups in cache.
if ! rm $TAR_CACHE_DIR/backup-*.tar.gz; then
  echo "Could not clear backup cache at '$TAR_CACHE_DIR'."
  exit_umount
fi
# Creates a backup in the cache.
if ! tar -cvpzf "$TAR_CACHE_DIR/$TAR_NAME" "$BACKUP_SRC"; then
  echo "Could not create tar '$TAR_CACHE_DIR/$TAR_NAME' from '$BACKUP_SRC'."
  exit_umount
fi
echo "Done"

echo "Moving backup tar to drive..."
# Checks size of backup tar.
TAR_SIZE=`du -BK "$TAR_CACHE_DIR/$TAR_NAME" | awk 'NR==1{print $1}'`
TAR_SIZE=${TAR_SIZE::-1}
echo "Tar Size: $TAR_SIZE KB"
# Checks free space on disk.
FREE_SPACE=`df $BACKUP_DRIVE_MOUNT_PT | awk 'NR==2{print $4}'`
FREE_SPACE=${FREE_SPACE::-1}
echo "Free Space: $FREE_SPACE KB"
# Compare space.
if [ ! $FREE_SPACE -ge $TAR_SIZE ]; then
  #TODO: Attempt to remove the oldest backup.
  echo "You do not have enough free space on the drive."
  exit_umount
fi
# Creates backup folder on drive.
if ! mkdir -p "$BACKUP_DRIVE_MOUNT_PT/$BACKUP_DRIVE_DIR"; then
  echo "Could not create backup directory at '$BACKUP_DRIVE_MOUNT_PT/$BACKUP_DRIVE_DIR'."
  exit_umount
fi
# Move backup tar.
if ! cp "$TAR_CACHE_DIR/$TAR_NAME" "$BACKUP_DRIVE_MOUNT_PT/$BACKUP_DRIVE_DIR"; then
  echo "Could not copy '$TAR_CACHE_DIR/$TAR_NAME' to '$BACKUP_DRIVE_MOUNT_PT/$BACKUP_DRIVE_DIR'."
  exit_umount
fi
echo "Done"

echo "Unmounting drive..."
if ! umount $BACKUP_DRIVE_MOUNT_PT; then
  echo "Could not unmount '$BACKUP_DRIVE_MOUNT_PT'."
  exit $?
fi
echo "Done"

echo "Finished backup $TIME."
exit 0
