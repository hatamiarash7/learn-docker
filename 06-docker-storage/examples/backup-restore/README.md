# Volume Backup and Restore

Scripts for backing up and restoring Docker volumes.

## Files

- `backup.sh` - Create timestamped backups of Docker volumes
- `restore.sh` - Restore volumes from backup files

## Usage

### Make scripts executable

```bash
chmod +x backup.sh restore.sh
```

### Create a backup

```bash
# Backup a volume
./backup.sh mysql-data

# Backup to specific directory
./backup.sh mysql-data /path/to/backups
```

### Restore from backup

```bash
# Restore to a new volume
./restore.sh ./backups/mysql-data_20240101_120000.tar.gz mysql-data-restored

# Restore to original volume name
./restore.sh ./backups/mysql-data_20240101_120000.tar.gz mysql-data
```

## Automatic Cleanup

The backup script automatically keeps only the last 5 backups for each volume.

## Manual Backup Commands

If you prefer not to use the scripts:

```bash
# Backup
docker run --rm \
    -v my-volume:/source:ro \
    -v $(pwd)/backups:/backup \
    alpine tar czf /backup/my-volume-backup.tar.gz -C /source .

# Restore
docker volume create my-volume-restored
docker run --rm \
    -v my-volume-restored:/target \
    -v $(pwd)/backups:/backup:ro \
    alpine sh -c "cd /target && tar xzf /backup/my-volume-backup.tar.gz"
```
