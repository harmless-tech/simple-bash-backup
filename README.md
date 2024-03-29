# Simple Bash backup
A simple backup system for linux that compresses a folder into a tar and moves it to another drive.

**These scripts will no longer recieve any updates!**

### Quick Setup
Run the command below and then edit the settings.env file.
```sh
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/harmless-tech/simple-bash-backup/main/setup.sh | bash
```
*This does not setup a [cron job](#timed-backups).*

### Configuration
Create a 'settings.env' file in the folder where the backup script is, then add the variables:

- ```BACKUP_SRC=``` - The folder you want to backup.

- ```BACKUP_DRIVE_MOUNT_PT=``` - Where you want the drive to be mounted.

- ```BACKUP_DRIVE_UUID=``` - The UUID of the partition of the drive you want mounted.

- ```BACKUP_DRIVE_DIR=``` The path on the drive where backups should go.

*All paths must be absolute paths. (e.g. /home/user/backup-me)*

### Running
- Make and fill out [settings.env](#configuration).
- Run ```chmod +x backup.sh``` to allow the backup script to run
- Run ```./backup.sh``` *Since mounting and unmounting drives usually requires root permissions you may need to run it with sudo.*

### Timed Backups
For timed backups you should add it to crontab.

*Since mounting and unmounting drives usually requires root permissions the commands below will add it to the root's crontab.
If you want to add it to your user's crontab remove sudo from the commands below.*

- Follow the [Running section](#running) to allow the backup script to be run
- Run ```sudo crontab -e```
- Add ```* * * * * /bin/bash /absolute/path/to/backup.sh```
*The \*'s here represent time, so ```00 02 * * *``` will run the script every night at 02:00:00.*

### Possible Future Additions
- Allow for deleting of old backups to free up space for new backups.
