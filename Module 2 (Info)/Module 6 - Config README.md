# Configuration Manager

Module 6 provides a centralized interface for viewing, exporting, importing, and managing all DClient module configuration files.

## Features

- **Settings Viewer**: View all module settings in one place
- **Export All**: Export all configuration files to a single text file
- **Import**: Restore settings from a previously exported file
- **Reset All**: Delete all configuration files to restore defaults
- **Refresh**: Reload settings from all configuration files

## Usage

1. **Launch Config Manager**:
   - Click "Config Manager" button in DClient Hub
   - Or run `StartConfigManager.bat`
   - Or launch `ConfigManager.ahk` directly

2. **View Settings**:
   - All module settings displayed automatically
   - Shows module name, Always On Top setting, and config file path
   - Click "Refresh" to reload settings

3. **Export Settings**:
   - Click "Export All" button
   - Settings exported to timestamped text file
   - File saved in Module 6 directory: `config_export_yyyy-MM-dd_HH-mm-ss.txt`
   - Contains all configuration files and their contents

4. **Import Settings**:
   - Click "Import" button
   - Select previously exported configuration file
   - Confirm import (will overwrite current settings)
   - Settings restored from export file
   - Restart affected modules for changes to take effect

5. **Reset Settings**:
   - Click "Reset All" button
   - Confirm reset (will delete all config files)
   - All modules will use defaults on next launch

## Managed Configuration Files

The Config Manager manages these configuration files:
- `Module 0 (Main)/hub_settings.ini` - DClient Hub settings
- `Module 11 (Errors)/errorviewer_settings.ini` - Error Viewer settings
- `Module 13 (Webserve)/subscripts/config/settings.ini` - Web Server settings
- `Module 13 (Webserve)/subscripts/config/htmleditor_settings.ini` - HTML Editor settings
- `Module 13 (Webserve)/subscripts/config/csseditor_settings.ini` - CSS Editor settings
- `Module 13 (Webserve)/subscripts/config/jseditor_settings.ini` - JS Editor settings

## Export Format

Exported files contain:
- Module name
- Config file path
- Always On Top setting
- Full file contents
- Separated by 60-character separator lines

## Files

- **ConfigManager.ahk** - Main configuration manager application
- **StartConfigManager.bat** - Launcher script
- **config/** - Config manager settings directory (optional)

## Notes

- Import requires exported files created by this module
- Import will overwrite existing configuration files
- Reset will permanently delete all configuration files
- Always restart modules after importing or resetting settings

