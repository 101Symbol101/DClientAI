# Backup Manager

Module 10 provides a backup and restore system for DClient configuration files and content files.

## Features

- **Create Backups**: Backup all config and content files with timestamps
- **Restore Backups**: Restore selected backup (overwrites current files)
- **Delete Backups**: Remove old backups
- **Backup List**: View all available backups with timestamps
- **Automatic Sorting**: Backups sorted by date (newest first)

## Usage

1. **Launch Backup Manager**:
   - Click "Backup Manager" button in DClient Hub
   - Or run `StartBackupManager.bat`
   - Or launch `BackupManager.ahk` directly

2. **Create Backup**:
   - Click "Create Backup" button
   - Backup created with timestamp: `backup_yyyy-MM-dd_HH-mm-ss`
   - Includes all config files and content files
   - Shows confirmation with backup name and file count

3. **Restore Backup**:
   - Select backup from list
   - Click "Restore" button
   - Confirm restore (will overwrite current files)
   - Files restored from backup
   - Restart affected modules for changes to take effect

4. **Delete Backup**:
   - Select backup from list
   - Click "Delete" button
   - Confirm deletion
   - Backup directory deleted permanently

5. **Refresh List**:
   - Click "Refresh" button to reload backup list
   - Backups automatically sorted by date (newest first)

## Backup Contents

Each backup includes:
- **Configuration Files**:
  - `hub_settings.ini` - DClient Hub settings
  - `errorviewer_settings.ini` - Error Viewer settings
  - `webserver_settings.ini` - Web Server settings
  - `htmleditor_settings.ini` - HTML Editor settings
  - `csseditor_settings.ini` - CSS Editor settings
  - `jseditor_settings.ini` - JS Editor settings

- **Content Files**:
  - `HTMLContent.ahk` - HTML content
  - `CSSContent.ahk` - CSS content
  - `JSContent.ahk` - JavaScript content

- **Metadata**:
  - `backup_info.txt` - Backup information (timestamp, file count)

## Backup Storage

- Backups stored in: `Module 10 (Backup)/backups/`
- Each backup is a separate directory
- Format: `backup_yyyy-MM-dd_HH-mm-ss/`
- Backups sorted by date (newest first)

## Files

- **BackupManager.ahk** - Main backup manager application
- **StartBackupManager.bat** - Launcher script
- **backups/** - Backup storage directory (created automatically)

## Notes

- Backups are complete snapshots of configuration and content
- Restore will overwrite current files
- Always restart modules after restoring a backup
- Delete backups to free up disk space
- Backups can be manually copied/moved if needed

