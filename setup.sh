#!/bin/sh

### Simple Bash Backup (Setup Script) by harmless-tech
### Version: 1
### Git: https://github.com/harmless-tech/simple-bash-backup
### License: MIT (https://github.com/harmless-tech/simple-bash-backup/blob/main/LICENSE)

echo "Simple Bash Backup (Setup Script) by harmless-tech (v1)"

#
BASE_URL="https://raw.githubusercontent.com/harmless-tech/simple-bash-backup/main"
SCRIPT_DIR=`pwd`
#

#
TOP_DIR="$SCRIPT_DIR/sbbackup"
SETTINGS_FILE="$TOP_DIR/settings.env"
UTILS_DIR="$TOP_DIR/utils"
#

# Check for curl command
if ! curl --version > /dev/null 2>&1; then
  echo "Could not find curl on the path, please install it."
  exit $?
fi

# Create Directories
if ! mkdir -p $TOP_DIR; then
  echo "Could not create top folder at '$TOP_DIR'."
  exit $?
fi

# if ! mkdir -p $UTILS_DIR; then
#   echo "Could not create utils folder at '$UTILS_DIR'."
#   exit $?
# fi

# Download Files
if ! curl --proto '=https' --tlsv1.2 -sSf "$BASE_URL/backup.sh" -o "$TOP_DIR/backup.sh"; then
  echo "Could not download backup.sh from '$BASE_URL/backup.sh' to '$TOP_DIR/backup.sh'."
  exit $?
fi

# Create Settings File
if ! touch "$SETTINGS_FILE"; then
  echo "Could not create settings.env at '$SETTINGS_FILE'."
  exit $?
fi

echo "BACKUP_SRC=" >> $SETTINGS_FILE
echo "BACKUP_DRIVE_MOUNT_PT=" >> $SETTINGS_FILE
echo "BACKUP_DRIVE_UUID=" >> $SETTINGS_FILE
echo "BACKUP_DRIVE_DIR=" >> $SETTINGS_FILE

# Give File Permissions
if ! chmod --version > /dev/null 2>&1; then
  echo "Could not find chmod on the path, you may need to grant permissions yourself."
  echo "Finished installing Simple Bash Backup to $TOP_DIR."
  exit $?
fi

chmod +x "$TOP_DIR/backup.sh"
#TODO: Utils

echo "Finished installing Simple Bash Backup to $TOP_DIR."
exit 0
