# DClient - Complete Documentation

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Module 0 (Main) - DClient Hub](#module-0-main---dclient-hub)
4. [Module 1 (Developer Only!) - Developer Module](#module-1-developer-only---developer-module)
5. [Module 3 (CSS) - CSS Editor](#module-3-css---css-editor)
6. [Module 4 (JS) - JavaScript Editor](#module-4-js---javascript-editor)
7. [Module 6 (Config) - Configuration Manager](#module-6-config---configuration-manager)
8. [Module 10 (Backup) - Backup Manager](#module-10-backup---backup-manager)
9. [Module 11 (Errors) - Centralized Error Logging](#module-11-errors---centralized-error-logging)
10. [Module 12 (HTML) - HTML Editor](#module-12-html---html-editor)
11. [Module 13 (Webserve) - Web Server Control Panel](#module-13-webserve---web-server-control-panel)
12. [File Dependencies](#file-dependencies)
13. [Configuration Files](#configuration-files)
14. [Usage Instructions](#usage-instructions)
15. [Technical Details](#technical-details)

---

## Overview

DClient is a modular AutoHotkey v2.0 application suite designed for web development and server management. The project consists of multiple interconnected modules that work together to provide a comprehensive development environment.

### Key Features
- **Central Hub**: Single entry point for all DClient components
- **Code Editors**: HTML, CSS, and JavaScript editors with validation and history tracking
- **Web Server**: Built-in HTTP server for local development
- **Error Logging**: Centralized error and message tracking system
- **Configuration Management**: Centralized settings viewer and import/export
- **Backup System**: Backup and restore configuration files
- **Modular Architecture**: Each module operates independently but integrates seamlessly

---

## Project Structure

```
DClient/
├── Module 0 (Main)/
│   ├── DClientHub.ahk          # Main hub GUI
│   ├── Start.bat                # Launcher script
│   └── DOCUMENTATION.md         # This file
│
├── Module 1 (Developer Only!)/
│   ├── DeveloperModule.ahk     # Password-protected developer module
│   ├── GeneratePasswordHash.ahk # Password hash generator tool
│   ├── StartDeveloperModule.bat # Launcher for developer module
│   ├── StartHashGenerator.bat  # Launcher for hash generator
│   └── README.md                # Developer module documentation
│
├── Module 2 (INFO)/
│   └── DOCUMENTATION.md         # Complete documentation
│
├── Module 3 (CSS)/
│   ├── CSSEditor.ahk            # CSS editor GUI
│   ├── StartCSSEditor.bat       # Launcher for CSS editor
│   └── data/                    # CSS edit history (timestamped files)
│
├── Module 4 (JS)/
│   ├── JSEditor.ahk             # JavaScript editor GUI
│   ├── StartJSEditor.bat        # Launcher for JS editor
│   └── data/                    # JS edit history (timestamped files)
│
├── Module 6 (Config)/
│   ├── ConfigManager.ahk         # Configuration manager GUI
│   ├── StartConfigManager.bat   # Launcher for config manager
│   └── config/                  # Config manager settings
│
├── Module 10 (Backup)/
│   ├── BackupManager.ahk         # Backup manager GUI
│   ├── StartBackupManager.bat   # Launcher for backup manager
│   └── backups/                 # Backup storage directory
│
├── Module 11 (Errors)/
│   ├── ErrorLogger.ahk          # Centralized logging system
│   ├── ErrorViewer.ahk          # Error viewer GUI
│   ├── ErrorHandlers.ahk        # Error handling patterns (reference)
│   ├── ErrorLocations.md        # Error location mapping
│   └── README.md                # Error module documentation
│
├── Module 12 (HTML)/
│   ├── HTMLEditor.ahk           # HTML editor GUI
│   └── data/                    # HTML edit history (timestamped files)
│
└── Module 13 (Webserve)/
    └── subscripts/
        ├── GlobalStart.ahk     # Web server control panel
        ├── HTMLContent.ahk      # HTML content storage
        ├── config/
        │   └── logs.txt         # Module 13 log file
        └── image_assets/
            └── Styles/          # UI skinning assets
```
**Quick Note**
This Section (modules 1-15) create files like config files that are not displayed in this diagram.

---

## Module 0 (Main) - DClient Hub

### Purpose
The DClient Hub serves as the central control panel for launching and managing all DClient components. It provides a unified interface to access all modules.

### Files

#### `DClientHub.ahk`
**Purpose**: Main hub GUI application

**Features**:
- **Launch Buttons**: 
  - HTML Editor - Opens the HTML editor module
  - CSS Editor - Opens the CSS editor module
  - JavaScript Editor - Opens the JavaScript editor module
  - Web Server Control - Opens the web server control panel
  - View Logs - Opens the Module 13 log file in Notepad
  - Error Viewer - Opens the centralized error viewer
  - Developer Module - Opens the password-protected developer module
  - Config Manager - Opens the configuration manager
  - Backup Manager - Opens the backup manager
- **Always On Top**: Checkbox to keep hub window above other windows
- **Close All**: When hub closes, it automatically closes all other open DClient windows
- **Settings Persistence**: Always On Top preference saved to `hub_settings.ini`

**Window Properties**:
- Width: 400px
- Height: 750px
- Dark theme with custom skinning
- Draggable title bar

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- All other module scripts (for launching)

**Configuration**:
- Settings file: `Module 0 (Main)/hub_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` (values: "0" or "1")

#### `Start.bat`
**Purpose**: Batch launcher script for users without AutoHotkey installed

**Functionality**:
1. Changes to script directory
2. Attempts to launch using bundled AutoHotkey executables:
   - First tries `AutoHotkey64.exe` from Module 13
   - Falls back to `AutoHotkey32.exe` from Module 13
3. If bundled executables not found, uses system-installed AutoHotkey
4. Shows error message if AutoHotkey cannot be found

**Usage**: Double-click `Start.bat` to launch DClient Hub

---

## Module 1 (Developer Only!) - Developer Module

### Purpose
Module 1 provides a password-protected area restricted to developers only. This module requires authentication before access is granted.

### Files

#### `DeveloperModule.ahk`
**Purpose**: Password-protected developer module GUI application

**Features**:
- **Password Protection**: Requires password entry before access
- **Password Prompt**: GUI dialog for password entry
- **Access Control**: Only grants access if password matches stored hash
- **Developer Interface**: Placeholder interface for developer tools and features

**Window Properties**:
- Width: 400px (password prompt), 400px (main module)
- Height: 300px (password prompt), 300px (main module)
- Dark theme with custom skinning
- Draggable title bar

**Password System**:
- Password stored as SHA-256 hash in code
- Password never stored in plain text
- Hash comparison for authentication
- Error message displayed on incorrect password

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- `Module 13 (Webserve)/subscripts/image_assets/Styles/` - UI skinning assets

#### `GeneratePasswordHash.ahk`
**Purpose**: Helper tool to generate password hashes for use in DeveloperModule.ahk

**Features**:
- **Password Input**: Secure password entry field
- **Hash Generation**: Generates SHA-256 hash of entered password
- **Hash Display**: Shows generated hash in read-only text field
- **Clipboard Copy**: Copies hash to clipboard for easy pasting

**Window Properties**:
- Width: 400px
- Height: 400px
- Dark theme with custom skinning
- Draggable title bar

**Usage**:
1. Enter desired password
2. Click "Generate Hash"
3. Copy hash from output field
4. Paste hash into DeveloperModule.ahk as PASSWORD_HASH value

#### `StartDeveloperModule.bat`
**Purpose**: Batch launcher script for DeveloperModule.ahk

**Functionality**: Same as Start.bat but launches DeveloperModule.ahk instead

#### `StartHashGenerator.bat`
**Purpose**: Batch launcher script for GeneratePasswordHash.ahk

**Functionality**: Same as Start.bat but launches GeneratePasswordHash.ahk instead

#### `README.md`
**Purpose**: Documentation for the developer module

**Content**: Setup instructions, security information, and usage guide

### Security Model

**Protection Level**:
- Prevents casual access by users without password knowledge
- Prevents accidental password exposure in code reviews or logs
- Provides basic access control for developer-only features

**Security Considerations**:
- This is local application protection, not enterprise-grade security
- Hash is visible in code to anyone with code access
- Strong passwords recommended for better protection
- Suitable for preventing casual access, not determined attackers

**Code Protection Methods**:

1. **Compile to Executable** (Recommended):
   - Use AutoHotkey compiler (Ahk2Exe) to compile `.ahk` files to `.exe`
   - Makes source code less accessible (but still reversible with tools)
   - Prevents casual users from easily viewing/modifying code
   - Users would need decompilation tools to access source

2. **Code Obfuscation**:
   - Use AutoHotkey obfuscation tools to make code harder to read
   - Renames variables/functions to meaningless names
   - Makes reverse engineering more difficult but not impossible

3. **Integrity Checks**:
   - Verify file hasn't been modified (checksums, digital signatures)
   - Exit if code integrity check fails
   - Prevents simple modifications but can be bypassed

4. **Server-Side Authentication** (Only Real Solution):
   - Move password verification to remote server
   - Application checks with server before granting access
   - Only truly secure method, but requires server infrastructure

**Limitations**:
- Anyone with executable can use decompilers to extract source
- Determined attackers can always bypass local protection
- Compiled executables can be reverse-engineered
- For maximum security, use server-side authentication

### Usage Instructions

**Setting Up Password**:
1. Run `GeneratePasswordHash.ahk` or `StartHashGenerator.bat`
2. Enter desired password
3. Click "Generate Hash"
4. Copy the generated hash
5. Open `DeveloperModule.ahk`
6. Find `PASSWORD_HASH` variable
7. Replace hash value with copied hash
8. Save file

**Accessing Developer Module**:
1. Launch DClient Hub
2. Click "Developer Module" button
3. Enter password when prompted
4. If correct, access granted to developer interface

**Changing Password**:
1. Generate new hash using `GeneratePasswordHash.ahk` (this requires a true developer key in order to access)
2. Replace `PASSWORD_HASH` value in `DeveloperModule.ahk`
3. Save file

### Default Configuration

**Default Password**:
- Default hash corresponds to empty password
- Change immediately after first use
- Use `GeneratePasswordHash.ahk` to set new password

### Important Notes

Attempting to access the developer module with the incorrect password 5 itmes will lock you out and require the lead developer to reset your attempts. 
Attempting to decrypt passwords may be allowed but if attempts to result in failure, we will not reset your attempts.
Attempting to bruteforce your entry will be detected and prevented, and we will not reset your attempts.
The decryption was written by hand and is unique to any other encoding method, and should be relatively hard to access. 
YOU ARE ALLOWED TO USE MODULE 1 if you manage to gain access to it which proves to us you have the advanced understanding in what you are doing and that we can trust you to be responsible.
---

## Module 3 (CSS) - CSS Editor

### Purpose
Module 3 provides a visual CSS editor with validation, history tracking, and integration with the web server.

### Files

#### `CSSEditor.ahk`
**Purpose**: CSS editing GUI application

**Features**:
- **CSS Text Box**: Large text area for editing CSS content
- **Send Button**: Validates and saves CSS to `CSSContent.ahk`
- **Always On Top**: Checkbox to keep window above other windows
- **Close Button**: Closes the CSS editor
- **CSS Validation**: Validates CSS before saving
- **Edit History**: Saves each successful edit as timestamped file in `data/` folder
- **Settings Persistence**: Always On Top preference saved to config

**Window Properties**:
- Width: 800px
- Height: 600px
- Dark theme with custom skinning
- Draggable title bar
- Monospace font (Consolas) for code editing

**CSS Validation**:
The `ValidateCSS()` function performs:
1. **Empty Check**: Ensures CSS content is not empty
2. **Rule Presence**: Verifies at least one CSS rule exists (contains `{}`, `:`, or `;`)
3. **Brace Balance**: Checks that opening/closing braces are properly matched

**Validation Errors**:
- "CSS content cannot be empty"
- "Invalid CSS: No CSS rules found"
- "Invalid CSS: Unmatched closing brace }"
- "Invalid CSS: Unclosed brace(s)"

**CSS Content Loading**:
- Reads from `Module 13 (Webserve)/subscripts/CSSContent.ahk`
- Supports multiple AutoHotkey continuation section formats:
  - `cssContent := "`n`n(`n...content...`)"`
  - `cssContent := "`n(`n...content...`)"`
  - `cssContent := "...content..."`

**CSS Content Saving**:
- Writes to `Module 13 (Webserve)/subscripts/CSSContent.ahk`
- Format: AutoHotkey continuation section with proper escaping
- Updates web server's CSS content immediately

**Edit History**:
- Each successful "Send" creates a new file in `Module 3 (CSS)/data/`
- Filename format: `yyyy-MM-dd_HH-mm-ss.css`
- Contains the CSS content that was saved
- Provides complete audit trail of all edits

**Logging**:
- All actions logged to `Module 13 (Webserve)/subscripts/config/logs.txt`
- Uses `LogMessage()` function for Module 13 logs
- Uses `LogError()` and `LogImportantMessage()` for centralized error log

**Configuration**:
- Settings file: `Module 13 (Webserve)/subscripts/config/csseditor_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` (values: "0" or "1")

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- `Module 13 (Webserve)/subscripts/CSSContent.ahk` - For CSS content storage
- `Module 13 (Webserve)/subscripts/config/logs.txt` - For action logging

**Directory Structure**:
```
Module 3 (CSS)/
├── CSSEditor.ahk
├── StartCSSEditor.bat
└── data/
    ├── 2024-01-15_14-30-25.css
    ├── 2024-01-15_14-35-10.css
    └── ...
```

---

## Module 4 (JS) - JavaScript Editor

### Purpose
Module 4 provides a visual JavaScript editor with validation, history tracking, and integration with the web server.

### Files

#### `JSEditor.ahk`
**Purpose**: JavaScript editing GUI application

**Features**:
- **JavaScript Text Box**: Large text area for editing JavaScript content
- **Send Button**: Validates and saves JavaScript to `JSContent.ahk`
- **Always On Top**: Checkbox to keep window above other windows
- **Close Button**: Closes the JavaScript editor
- **JavaScript Validation**: Validates JavaScript before saving
- **Edit History**: Saves each successful edit as timestamped file in `data/` folder
- **Settings Persistence**: Always On Top preference saved to config

**Window Properties**:
- Width: 800px
- Height: 600px
- Dark theme with custom skinning
- Draggable title bar
- Monospace font (Consolas) for code editing

**JavaScript Validation**:
The `ValidateJS()` function performs:
1. **Empty Check**: Ensures JavaScript content is not empty
2. **Brace Balance**: Checks that opening/closing braces `{}` are properly matched
3. **Parenthesis Balance**: Checks that opening/closing parentheses `()` are properly matched
4. **Bracket Balance**: Checks that opening/closing brackets `[]` are properly matched

**Validation Errors**:
- "JavaScript content cannot be empty"
- "Invalid JavaScript: Unmatched closing brace }"
- "Invalid JavaScript: Unclosed brace(s)"
- "Invalid JavaScript: Unmatched closing parenthesis )"
- "Invalid JavaScript: Unclosed parenthesis/parentheses"
- "Invalid JavaScript: Unmatched closing bracket ]"
- "Invalid JavaScript: Unclosed bracket(s)"

**JavaScript Content Loading**:
- Reads from `Module 13 (Webserve)/subscripts/JSContent.ahk`
- Supports multiple AutoHotkey continuation section formats:
  - `jsContent := "`n`n(`n...content...`)"`
  - `jsContent := "`n(`n...content...`)"`
  - `jsContent := "...content..."`

**JavaScript Content Saving**:
- Writes to `Module 13 (Webserve)/subscripts/JSContent.ahk`
- Format: AutoHotkey continuation section with proper escaping
- Updates web server's JavaScript content immediately

**Edit History**:
- Each successful "Send" creates a new file in `Module 4 (JS)/data/`
- Filename format: `yyyy-MM-dd_HH-mm-ss.js`
- Contains the JavaScript content that was saved
- Provides complete audit trail of all edits

**Logging**:
- All actions logged to `Module 13 (Webserve)/subscripts/config/logs.txt`
- Uses `LogMessage()` function for Module 13 logs
- Uses `LogError()` and `LogImportantMessage()` for centralized error log

**Configuration**:
- Settings file: `Module 13 (Webserve)/subscripts/config/jseditor_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` (values: "0" or "1")

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- `Module 13 (Webserve)/subscripts/JSContent.ahk` - For JavaScript content storage
- `Module 13 (Webserve)/subscripts/config/logs.txt` - For action logging

**Directory Structure**:
```
Module 4 (JS)/
├── JSEditor.ahk
├── StartJSEditor.bat
└── data/
    ├── 2024-01-15_14-30-25.js
    ├── 2024-01-15_14-35-10.js
    └── ...
```

---

## Module 6 (Config) - Configuration Manager

### Purpose
Module 6 provides a centralized interface for viewing, exporting, importing, and managing all DClient module configuration files.

### Files

#### `ConfigManager.ahk`
**Purpose**: Configuration management GUI application

**Features**:
- **Settings Display**: Shows all module settings in a read-only text view
- **Refresh Button**: Reloads settings from all configuration files
- **Export All Button**: Exports all configuration files to a single text file
- **Import Button**: Imports settings from a previously exported configuration file
- **Reset All Button**: Deletes all configuration files to restore defaults
- **Settings Persistence**: No local settings (read-only viewer)

**Window Properties**:
- Width: 500px
- Height: 500px
- Dark theme with custom skinning
- Draggable title bar
- Read-only text display

**Managed Configuration Files**:
- `Module 0 (Main)/hub_settings.ini` - DClient Hub settings
- `Module 11 (Errors)/errorviewer_settings.ini` - Error Viewer settings
- `Module 13 (Webserve)/subscripts/config/settings.ini` - Web Server settings
- `Module 13 (Webserve)/subscripts/config/htmleditor_settings.ini` - HTML Editor settings
- `Module 13 (Webserve)/subscripts/config/csseditor_settings.ini` - CSS Editor settings
- `Module 13 (Webserve)/subscripts/config/jseditor_settings.ini` - JS Editor settings

**Export Format**:
- Text file with timestamp: `config_export_yyyy-MM-dd_HH-mm-ss.txt`
- Contains module name, config file path, Always On Top setting, and full file contents
- Separated by 60-character separator lines

**Import Functionality**:
- Reads exported configuration files
- Parses and restores individual INI files
- Creates directories if needed
- Shows confirmation with number of files restored
- Requires user confirmation before overwriting

**Reset Functionality**:
- Deletes all configuration files
- Requires user confirmation
- Shows count of deleted files
- All modules will use defaults on next launch

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging

**Directory Structure**:
```
Module 6 (Config)/
├── ConfigManager.ahk
├── StartConfigManager.bat
└── config/
    └── config_manager.ini (if created)
```

---

## Module 10 (Backup) - Backup Manager

### Purpose
Module 10 provides a backup and restore system for DClient configuration files and content files.

### Files

#### `BackupManager.ahk`
**Purpose**: Backup and restore GUI application

**Features**:
- **Backup List**: Displays all available backups with timestamps
- **Create Backup Button**: Creates a new backup of all config and content files
- **Restore Button**: Restores selected backup (overwrites current files)
- **Delete Button**: Deletes selected backup
- **Refresh Button**: Reloads backup list

**Window Properties**:
- Width: 600px
- Height: 500px
- Dark theme with custom skinning
- Draggable title bar
- List box for backup selection

**Backup Contents**:
Each backup includes:
- `hub_settings.ini` - DClient Hub settings
- `errorviewer_settings.ini` - Error Viewer settings
- `webserver_settings.ini` - Web Server settings
- `htmleditor_settings.ini` - HTML Editor settings
- `csseditor_settings.ini` - CSS Editor settings
- `jseditor_settings.ini` - JS Editor settings
- `HTMLContent.ahk` - HTML content
- `CSSContent.ahk` - CSS content
- `JSContent.ahk` - JavaScript content
- `backup_info.txt` - Backup metadata (timestamp, file count)

**Backup Storage**:
- Backups stored in `Module 10 (Backup)/backups/`
- Directory format: `backup_yyyy-MM-dd_HH-mm-ss`
- Each backup is a separate directory
- Backups sorted by date (newest first)

**Restore Process**:
1. User selects backup from list
2. Confirmation dialog shown
3. Files copied from backup directory to original locations
4. Directories created if needed
5. Confirmation shown with number of files restored
6. User advised to restart affected modules

**Backup Creation**:
- Creates timestamped backup directory
- Copies all config and content files
- Creates backup info file
- Shows confirmation with backup name and file count

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging

**Directory Structure**:
```
Module 10 (Backup)/
├── BackupManager.ahk
├── StartBackupManager.bat
└── backups/
    ├── backup_2024-01-15_14-30-25/
    │   ├── backup_info.txt
    │   ├── hub_settings.ini
    │   ├── HTMLContent.ahk
    │   └── ...
    └── backup_2024-01-15_15-45-10/
        └── ...
```

---

## Module 11 (Errors) - Centralized Error Logging

### Purpose
Module 11 provides a centralized error and message logging system that all other DClient modules use. This ensures consistent error tracking and makes debugging easier.

### Files

#### `ErrorLogger.ahk`
**Purpose**: Core logging functions used by all modules

**Functions**:

1. **`InitializeErrorLogger()`**
   - Creates the error log directory if it doesn't exist
   - Called automatically on script load

2. **`LogError(moduleName, errorContext, errorMessage, errorDetails := "")`**
   - Logs errors to `error_log.txt`
   - Format: `[timestamp] [ERROR] [ModuleName] Context: Message | Details: details`
   - Used for actual errors and exceptions

3. **`LogImportantMessage(moduleName, messageContext, message, details := "")`**
   - Logs important non-error messages to `error_log.txt`
   - Format: `[timestamp] [INFO] [ModuleName] Context: Message | Details: details`
   - Used for application lifecycle events (start, stop, important actions)
   - **Note**: All important messages go to error log, not separate files

4. **`LogWarning(moduleName, warningContext, warningMessage, details := "")`**
   - Logs warnings to `error_log.txt`
   - Format: `[timestamp] [WARNING] [ModuleName] Context: Message | Details: details`
   - Used for non-critical issues

5. **`SafeGetErrorMessage(err)`**
   - Safely extracts error message from error objects
   - Handles different error object types

6. **`GetErrorLog()`**
   - Returns contents of `error_log.txt` as string
   - Returns empty string if file doesn't exist or can't be read

**Log File**: `Module 11 (Errors)/error_log.txt`

**Log Format**:
```
[2024-01-15 14:30:25] [ERROR] [HTMLEditor] ValidateHTML: Invalid HTML: No HTML tags found | Details: 
[2024-01-15 14:30:30] [INFO] [HTMLEditor] ApplicationStart: HTML Editor window opened
[2024-01-15 14:30:45] [WARNING] [GlobalStart] LoadSettings: Config file not found, using defaults
```

#### `ErrorViewer.ahk`
**Purpose**: GUI application for viewing centralized error logs

**Features**:
- **Display**: Shows all errors, warnings, and important messages from `error_log.txt`
- **Refresh Button**: Reloads error log from file
- **Clear Errors Button**: Deletes `error_log.txt` (with confirmation dialog)
- **Always On Top**: Checkbox to keep window above other windows
- **Close Button**: Closes the error viewer
- **Settings Persistence**: Always On Top preference saved to `errorviewer_settings.ini`

**Window Properties**:
- Width: 800px
- Height: 600px
- Dark theme with custom skinning
- Draggable title bar
- Read-only text display

**Confirmation Dialog**:
- Custom GUI with checkbox
- User must check "I understand this action cannot be undone" to enable "Yes" button
- Prevents accidental log deletion

**Configuration**:
- Settings file: `Module 11 (Errors)/errorviewer_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` (values: "0" or "1")

**Dependencies**:
- `ErrorLogger.ahk` - For logging actions

#### `ErrorHandlers.ahk`
**Purpose**: Reference documentation for error handling patterns

**Content**: Commented code examples showing:
- File operation error handling
- GUI creation error handling
- Settings file error handling
- Retry logic patterns
- Silent fail patterns
- Log and show patterns

**Note**: This is a reference file, not actively used code.

#### `ErrorLocations.md`
**Purpose**: Maps error patterns to their locations in the codebase

**Content**: Documentation of where different types of errors occur and how they're handled.

#### `README.md`
**Purpose**: Overview and usage guide for the error handling system

---

## Module 12 (HTML) - HTML Editor

### Purpose
Module 12 provides a visual HTML editor with validation, history tracking, and integration with the web server.

### Files

#### `HTMLEditor.ahk`
**Purpose**: HTML editing GUI application

**Features**:
- **HTML Text Box**: Large text area for editing HTML content
- **Send Button**: Validates and saves HTML to `HTMLContent.ahk`
- **Always On Top**: Checkbox to keep window above other windows
- **Close Button**: Closes the HTML editor
- **HTML Validation**: Validates HTML before saving
- **Edit History**: Saves each successful edit as timestamped file in `data/` folder
- **Settings Persistence**: Always On Top preference saved to config

**Window Properties**:
- Width: 800px
- Height: 600px
- Dark theme with custom skinning
- Draggable title bar
- Monospace font (Consolas) for code editing

**HTML Validation**:
The `ValidateHTML()` function performs:
1. **Empty Check**: Ensures HTML content is not empty
2. **Tag Presence**: Verifies at least one HTML tag exists
3. **Tag Balance**: Checks that opening/closing tags are properly matched
4. **Void Elements**: Handles self-closing tags (img, br, hr, etc.)
5. **Self-Closing Tags**: Recognizes tags ending with `/>`

**Validation Errors**:
- "HTML content cannot be empty"
- "Invalid HTML: No HTML tags found"
- "Invalid HTML: Unmatched closing tag </tagname>"
- "Invalid HTML: Unclosed tag(s): tagname"

**HTML Content Loading**:
- Reads from `Module 13 (Webserve)/subscripts/HTMLContent.ahk`
- Supports multiple AutoHotkey continuation section formats:
  - `htmlContent := "`n`n(`n...content...`)"`
  - `htmlContent := "`n(`n...content...`)"`
  - `htmlContent := "...content..."`

**HTML Content Saving**:
- Writes to `Module 13 (Webserve)/subscripts/HTMLContent.ahk`
- Format: AutoHotkey continuation section with proper escaping
- Updates web server's HTML content immediately

**Edit History**:
- Each successful "Send" creates a new file in `Module 12 (HTML)/data/`
- Filename format: `yyyy-MM-dd_HH-mm-ss.txt`
- Contains the HTML content that was saved
- Provides complete audit trail of all edits

**Logging**:
- All actions logged to `Module 13 (Webserve)/subscripts/config/logs.txt`
- Uses `LogMessage()` function for Module 13 logs
- Uses `LogError()` and `LogImportantMessage()` for centralized error log

**Configuration**:
- Settings file: `Module 13 (Webserve)/subscripts/config/htmleditor_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` (values: "0" or "1")

**Dependencies**:
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- `Module 13 (Webserve)/subscripts/HTMLContent.ahk` - For HTML content storage
- `Module 13 (Webserve)/subscripts/config/logs.txt` - For action logging

**Directory Structure**:
```
Module 12 (HTML)/
├── HTMLEditor.ahk
└── data/
    ├── 2024-01-15_14-30-25.txt
    ├── 2024-01-15_14-35-10.txt
    └── ...
```

---

## Module 13 (Webserve) - Web Server Control Panel

### Purpose
Module 13 provides a web server for local development and a control panel for managing it.

### Files

#### `GlobalStart.ahk`
**Purpose**: Web server control panel GUI application

**Features**:
- **Server Control**: Start/stop web server
- **Status Display**: Shows current server status (Running/Stopped)
- **Server Address**: Displays server URL
- **Open Browser Button**: Opens server URL in default browser
- **Log Viewer**: Opens/closes log viewer window
- **Always On Top**: Checkbox to keep window above other windows
- **Close Button**: Closes the control panel
- **Window Position**: Remembers and restores window positions
- **Settings Persistence**: All preferences saved to config

**Window Properties**:
- Width: 240px (main panel)
- Height: 400px (main panel)
- Log window: 600px × 500px
- Dark theme with custom skinning
- Draggable title bars

**Server Functionality**:
- **Port**: 8080 (default)
- **Host**: localhost
- **URL**: http://localhost:8080
- **Web Root**: `Module 13 (Webserve)/subscripts/www/`
- **Index File**: `www/index.html` (generated from `HTMLContent.ahk`)

**Server Start Process**:
1. Checks cooldown timer (10 second cooldown between start/stop)
2. Verifies server is not already running
3. Creates `www/` directory if needed
4. Writes `index.html` from `HTMLContent.ahk` content
5. Initializes web server on port 8080
6. Updates UI to show "Running" status
7. Enables/disables buttons appropriately

**Server Stop Process**:
1. Checks cooldown timer
2. Verifies server is running
3. Stops server instance
4. Updates UI to show "Stopped" status
5. Enables/disables buttons appropriately

**Log Viewer**:
- Separate window showing all log entries
- Color-coded log entries (RTF format):
  - Red: Errors, failures, stopped
  - Green: Success, running, started, ready
  - Orange: Warnings, wait
  - Blue: Application lifecycle events
  - Light Blue: File operations (saving, loading, creating, writing)
  - Gray: Default
- Scrolls to top when opened
- Refresh button to reload logs
- Clear logs button (deletes log file)

**Logging System**:
- Logs written to: `Module 13 (Webserve)/subscripts/config/logs.txt`
- Format: `[timestamp] message`
- RTF formatting for colored display in log viewer
- Logs persist between sessions
- Loads previous logs on startup

**Hotkeys**:
- `Ctrl+S`: Start server
- `Ctrl+X`: Stop server
- `Ctrl+Q`: Stop server (alternative)
- `Ctrl+R`: Reload script

**Window Position Saving**:
- Saves main window position every second
- Saves log window position when closed
- Restores positions on next launch
- Settings stored in `settings.ini`

**Configuration**:
- Settings file: `Module 13 (Webserve)/subscripts/config/settings.ini`
- Sections:
  - `[Window]` - AlwaysOnTop preference
  - `[MainWindow]` - Main window position (X, Y, W, H)
  - `[LogWindow]` - Log window position (X, Y, W, H)

**Dependencies**:
- `lib/WebServe.ahk` - Web server library
- `HTMLContent.ahk` - HTML content source
- `CSSContent.ahk` - CSS content source (optional)
- `JSContent.ahk` - JavaScript content source (optional)
- `Module 11 (Errors)/ErrorLogger.ahk` - For error logging
- `image_assets/Styles/` - UI skinning assets

#### `HTMLContent.ahk`
**Purpose**: Stores HTML content served by web server

**Format**:
```autohotkey
#Requires AutoHotkey v2.0
htmlContent := "`n`n
(
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebServe</title>
</head>
<body>
    <h1>Hi</h1>
</body>
</html>
)"
```

**Usage**:
- Read by `GlobalStart.ahk` to generate `www/index.html`
- Updated by `HTMLEditor.ahk` when user saves HTML
- Uses AutoHotkey continuation section for multi-line strings

#### `CSSContent.ahk`
**Purpose**: Stores CSS content (optional, created by CSS Editor)

**Format**: Same as HTMLContent.ahk but stores CSS

**Usage**:
- Created and updated by `CSSEditor.ahk` when user saves CSS
- Can be integrated into web server's HTML output
- Uses AutoHotkey continuation section for multi-line strings

#### `JSContent.ahk`
**Purpose**: Stores JavaScript content (optional, created by JS Editor)

**Format**: Same as HTMLContent.ahk but stores JavaScript

**Usage**:
- Created and updated by `JSEditor.ahk` when user saves JavaScript
- Can be integrated into web server's HTML output
- Uses AutoHotkey continuation section for multi-line strings

**Directory Structure**:
```
Module 13 (Webserve)/
└── subscripts/
    ├── GlobalStart.ahk
    ├── HTMLContent.ahk
    ├── CSSContent.ahk (optional)
    ├── JSContent.ahk (optional)
    ├── lib/
    │   └── WebServe.ahk
    ├── config/
    │   ├── logs.txt
    │   └── settings.ini
    ├── www/
    │   └── index.html (generated)
    └── image_assets/
        └── Styles/
            ├── Concaved.msstyles
            └── USkin.dll
```

---

## File Dependencies

### Dependency Graph

```
DClientHub.ahk
├── ErrorLogger.ahk (Module 11)
└── Launches:
    ├── DeveloperModule.ahk (Module 1)
    ├── CSSEditor.ahk (Module 3)
    ├── JSEditor.ahk (Module 4)
    ├── ConfigManager.ahk (Module 6)
    ├── BackupManager.ahk (Module 10)
    ├── HTMLEditor.ahk (Module 12)
    ├── GlobalStart.ahk (Module 13)
    └── ErrorViewer.ahk (Module 11)

HTMLEditor.ahk
├── ErrorLogger.ahk (Module 11)
├── HTMLContent.ahk (Module 13)
└── logs.txt (Module 13)

CSSEditor.ahk
├── ErrorLogger.ahk (Module 11)
├── CSSContent.ahk (Module 13)
└── logs.txt (Module 13)

JSEditor.ahk
├── ErrorLogger.ahk (Module 11)
├── JSContent.ahk (Module 13)
└── logs.txt (Module 13)

ConfigManager.ahk
└── ErrorLogger.ahk (Module 11)

BackupManager.ahk
└── ErrorLogger.ahk (Module 11)

GlobalStart.ahk
├── ErrorLogger.ahk (Module 11)
├── WebServe.ahk (Module 13/lib)
├── HTMLContent.ahk (Module 13)
├── CSSContent.ahk (Module 13)
├── JSContent.ahk (Module 13)
└── UI assets (Module 13/image_assets)

ErrorViewer.ahk
└── ErrorLogger.ahk (Module 11)
```

### Critical Files
- **ErrorLogger.ahk**: Required by all modules for logging
- **HTMLContent.ahk**: Required by HTMLEditor and GlobalStart
- **CSSContent.ahk**: Required by CSSEditor and GlobalStart
- **JSContent.ahk**: Required by JSEditor and GlobalStart
- **WebServe.ahk**: Required by GlobalStart for web server functionality
- **UI Assets**: Required for consistent theming across all GUIs
- **DeveloperModule.ahk**: Optional password-protected developer module

---

## Configuration Files

### Module 0 (Main)
- **`hub_settings.ini`**
  - Section: `[Window]`
  - Key: `AlwaysOnTop` ("0" or "1")

### Module 11 (Errors)
- **`errorviewer_settings.ini`**
  - Section: `[Window]`
  - Key: `AlwaysOnTop` ("0" or "1")
- **`error_log.txt`**
  - Centralized error, warning, and info log
  - Format: `[timestamp] [LEVEL] [Module] Context: Message | Details: details`

### Module 3 (CSS)
- **`csseditor_settings.ini`** (in Module 13 config directory)
  - Section: `[Window]`
  - Key: `AlwaysOnTop` ("0" or "1")

### Module 4 (JS)
- **`jseditor_settings.ini`** (in Module 13 config directory)
  - Section: `[Window]`
  - Key: `AlwaysOnTop` ("0" or "1")

### Module 6 (Config)
- **`config_manager.ini`** (optional, in Module 6 config directory)
  - Currently unused, reserved for future settings

### Module 10 (Backup)
- **`backups/`** directory
  - Contains timestamped backup directories
  - Each backup includes config files and content files

### Module 12 (HTML)
- **`htmleditor_settings.ini`** (in Module 13 config directory)
  - Section: `[Window]`
  - Key: `AlwaysOnTop` ("0" or "1")

### Module 13 (Webserve)
- **`settings.ini`**
  - Section: `[Window]`
    - Key: `AlwaysOnTop` ("0" or "1")
  - Section: `[MainWindow]`
    - Keys: `X`, `Y`, `W`, `H` (window position and size)
  - Section: `[LogWindow]`
    - Keys: `X`, `Y`, `W`, `H` (log window position and size)
- **`logs.txt`**
  - Module 13 specific log file
  - Format: `[timestamp] message`
  - Used by log viewer for colored display

---

## Usage Instructions

### Starting DClient

#### Method 1: Using Start.bat (Recommended for users without AutoHotkey)
1. Navigate to `Module 0 (Main)/`
2. Double-click `Start.bat`
3. DClient Hub will open

#### Method 2: Direct AutoHotkey Launch
1. Ensure AutoHotkey v2.0 is installed
2. Navigate to `Module 0 (Main)/`
3. Double-click `DClientHub.ahk` or right-click → Run Script
4. DClient Hub will open

### Using the HTML Editor

1. **Open HTML Editor**:
   - Click "HTML Editor" button in DClient Hub
   - Or launch `Module 12 (HTML)/HTMLEditor.ahk` directly

2. **Edit HTML**:
   - HTML content loads automatically from `HTMLContent.ahk`
   - Edit HTML in the text box
   - Use "Always On Top" checkbox if needed

3. **Save HTML**:
   - Click "Send" button
   - HTML is validated automatically
   - If valid, saves to `HTMLContent.ahk` and creates history file
   - If invalid, shows error message

4. **View Edit History**:
   - Navigate to `Module 12 (HTML)/data/`
   - Each file is timestamped with the HTML content at that time

### Using the CSS Editor

1. **Open CSS Editor**:
   - Click "CSS Editor" button in DClient Hub
   - Or launch `Module 3 (CSS)/CSSEditor.ahk` directly

2. **Edit CSS**:
   - CSS content loads automatically from `CSSContent.ahk` (if exists)
   - Edit CSS in the text box
   - Use "Always On Top" checkbox if needed

3. **Save CSS**:
   - Click "Send" button
   - CSS is validated automatically (checks for braces matching)
   - If valid, saves to `CSSContent.ahk` and creates history file
   - If invalid, shows error message

4. **View Edit History**:
   - Navigate to `Module 3 (CSS)/data/`
   - Each file is timestamped with the CSS content at that time

### Using the JavaScript Editor

1. **Open JavaScript Editor**:
   - Click "JavaScript Editor" button in DClient Hub
   - Or launch `Module 4 (JS)/JSEditor.ahk` directly

2. **Edit JavaScript**:
   - JavaScript content loads automatically from `JSContent.ahk` (if exists)
   - Edit JavaScript in the text box
   - Use "Always On Top" checkbox if needed

3. **Save JavaScript**:
   - Click "Send" button
   - JavaScript is validated automatically (checks braces, parentheses, brackets)
   - If valid, saves to `JSContent.ahk` and creates history file
   - If invalid, shows error message

4. **View Edit History**:
   - Navigate to `Module 4 (JS)/data/`
   - Each file is timestamped with the JavaScript content at that time

### Using the Configuration Manager

1. **Open Config Manager**:
   - Click "Config Manager" button in DClient Hub
   - Or launch `Module 6 (Config)/ConfigManager.ahk` directly

2. **View Settings**:
   - All module settings displayed in read-only view
   - Shows module name, Always On Top setting, and config file path
   - Click "Refresh" to reload settings

3. **Export Settings**:
   - Click "Export All" button
   - Settings exported to timestamped text file in Module 6 directory
   - File contains all configuration files and their contents

4. **Import Settings**:
   - Click "Import" button
   - Select previously exported configuration file
   - Confirm import (will overwrite current settings)
   - Settings restored from export file

5. **Reset Settings**:
   - Click "Reset All" button
   - Confirm reset (will delete all config files)
   - All modules will use defaults on next launch

### Using the Backup Manager

1. **Open Backup Manager**:
   - Click "Backup Manager" button in DClient Hub
   - Or launch `Module 10 (Backup)/BackupManager.ahk` directly

2. **Create Backup**:
   - Click "Create Backup" button
   - Backup created with timestamp
   - Includes all config files and content files (HTML, CSS, JS)
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
   - Backup directory deleted

5. **Refresh List**:
   - Click "Refresh" button to reload backup list
   - Backups sorted by date (newest first)

### Using the Web Server

1. **Open Web Server Control**:
   - Click "Web Server Control" button in DClient Hub
   - Or launch `Module 13 (Webserve)/subscripts/GlobalStart.ahk` directly

2. **Start Server**:
   - Click "Start Server" button
   - Wait for "Running" status
   - Server URL displayed: http://localhost:8080

3. **View Website**:
   - Click "Open Browser" button
   - Or navigate to http://localhost:8080 manually

4. **View Logs**:
   - Click "View Logs" button (or "Logs" button in control panel)
   - Log viewer opens showing all server activity
   - Color-coded entries for easy reading

5. **Stop Server**:
   - Click "Stop Server" button
   - Wait for "Stopped" status

### Using the Error Viewer

1. **Open Error Viewer**:
   - Click "Error Viewer" button in DClient Hub
   - Or launch `Module 11 (Errors)/ErrorViewer.ahk` directly

2. **View Errors**:
   - All errors, warnings, and important messages displayed
   - Scrollable text view
   - Click "Refresh" to reload from file

3. **Clear Errors**:
   - Click "Clear Errors" button
   - Confirm in dialog (must check checkbox)
   - Error log file is deleted

### Viewing Module 13 Logs

1. **From Hub**:
   - Click "View Logs" button in DClient Hub
   - Opens `logs.txt` in Notepad

2. **From Control Panel**:
   - Click "Logs" button in web server control panel
   - Opens log viewer window with colored display

---

## Technical Details

### AutoHotkey Version
- **Required**: AutoHotkey v2.0
- **Compatibility**: Not compatible with v1.x

### GUI Framework
- Uses AutoHotkey v2.0 native GUI system
- Custom dark theme applied via `ApplyDarkTheme()`
- Window skinning via USkin library (`ApplySkin()`)

### Window Management
- **Draggable Windows**: All GUIs use custom title bars for dragging
- **Always On Top**: Available on all main windows
- **Position Persistence**: Web server control panel remembers positions

### Error Handling
- **Centralized Logging**: All modules use `ErrorLogger.ahk`
- **Error Types**:
  - **ERROR**: Actual errors and exceptions
  - **WARNING**: Non-critical issues
  - **INFO**: Important non-error messages (application lifecycle)
- **Error Log Location**: `Module 11 (Errors)/error_log.txt`

### HTML Validation
- **Basic Validation**: Checks for tags, balance, void elements
- **Not Full HTML5 Parser**: Simple regex-based validation
- **Void Elements Handled**: area, base, br, col, embed, hr, img, input, link, meta, param, source, track, wbr

### File Paths
- **Relative Paths**: All paths use `A_ScriptDir` and relative navigation
- **Cross-Module Access**: Uses `..\` to navigate between modules
- **Path Format**: Windows-style paths with backslashes

### Logging Architecture
- **Module 13 Logs**: Action logs in `Module 13 (Webserve)/subscripts/config/logs.txt`
- **Centralized Logs**: Errors/info in `Module 11 (Errors)/error_log.txt`
- **Dual Logging**: Some actions logged to both systems
- **Log Format**: Timestamped entries with module context

### Web Server
- **Library**: Uses `WebServe.ahk` library
- **Port**: 8080 (hardcoded)
- **Host**: localhost (hardcoded)
- **Cooldown**: 10 second cooldown between start/stop operations
- **Web Root**: `www/` directory in Module 13 subscripts

### Settings Management
- **INI Format**: All settings use Windows INI file format
- **Auto-Creation**: Config directories and files created automatically
- **Default Values**: Sensible defaults if config files missing

### UI Theming
- **Dark Theme**: Consistent dark theme across all GUIs
- **Color Scheme**: 
  - Background: #2B2B2B
  - Text: White/Light Gray
  - Accents: Various colors for log entries
- **Fonts**: Segoe UI for UI, Consolas for code/logs
- **Skinning**: USkin library for custom window appearance

### Module Communication
- **No Direct Communication**: Modules don't communicate directly
- **File-Based**: Communication via shared files (HTMLContent.ahk, logs.txt)
- **Hub Coordination**: DClient Hub launches modules but doesn't control them
- **Window Closing**: Hub closes all DClient windows when it closes

### Startup Sequence
1. User launches DClient Hub
2. Hub loads settings
3. Hub displays launch buttons
4. User clicks button to launch module
5. Module initializes:
   - Loads settings
   - Creates GUI
   - Applies theme/skin
   - Loads data (HTML, logs, etc.)
   - Registers event handlers
   - Shows window

### Shutdown Sequence
1. User closes window or clicks Close button
2. Module saves settings
3. Module logs shutdown message
4. Module destroys GUI
5. Module exits

### Portability
- **Bundled Executables**: AutoHotkey64.exe and AutoHotkey32.exe in Module 13
- **Start.bat**: Allows running without AutoHotkey installation
- **Relative Paths**: All paths relative, making project portable
- **No Registry**: No registry dependencies

### Performance Considerations
- **Log File Size**: Logs can grow large over time
- **Window Position Saving**: Saves every second (may impact performance)
- **RTF Rendering**: Log viewer uses RTF for colors (may be slow with many entries)
- **File Locking**: Retry logic handles file locking issues

### Security Considerations
- **Local Only**: Web server only accessible on localhost
- **No Authentication**: No user authentication required
- **File Access**: Modules can read/write files in their directories
- **No Network**: No external network communication

### Known Limitations
- **HTML Validation**: Basic validation only, not full HTML5 parser
- **CSS Validation**: Basic validation only (brace matching), not full CSS parser
- **JavaScript Validation**: Basic validation only (syntax matching), not full JS parser
- **Single Server Instance**: Only one server instance can run
- **Port Hardcoded**: Port 8080 cannot be changed without code modification
- **No HTTPS**: Web server only supports HTTP
- **Windows Only**: AutoHotkey is Windows-only
- **Content Integration**: CSS and JS content files are created but not automatically integrated into HTML output

### Future Enhancement Possibilities
- Configurable server port
- Multiple server instances
- Enhanced HTML validation
- HTTPS support
- Module communication API
- Plugin system
- Configuration GUI
- Log filtering/search
- Export logs functionality
- Server statistics/metrics

---

## Troubleshooting

### Hub Won't Launch
- **Check**: AutoHotkey v2.0 installed or bundled executables present
- **Solution**: Install AutoHotkey v2.0 or ensure Start.bat can find executables

### HTML Editor Can't Load Content
- **Check**: `HTMLContent.ahk` exists in Module 13 subscripts
- **Solution**: Ensure file exists and is readable

### CSS Editor Can't Load Content
- **Check**: `CSSContent.ahk` exists in Module 13 subscripts (optional)
- **Solution**: File is created automatically on first save, or start with empty content

### JavaScript Editor Can't Load Content
- **Check**: `JSContent.ahk` exists in Module 13 subscripts (optional)
- **Solution**: File is created automatically on first save, or start with empty content

### Config Manager Import Fails
- **Check**: Export file format is correct
- **Solution**: Use files exported by Config Manager, ensure file is not corrupted

### Backup Manager Can't Restore
- **Check**: Backup directory exists and contains files
- **Solution**: Verify backup directory structure, check file permissions

### Web Server Won't Start
- **Check**: Port 8080 not in use, cooldown timer expired
- **Solution**: Wait 10 seconds between start/stop, check port availability

### Errors Not Showing in Error Viewer
- **Check**: `error_log.txt` exists in Module 11
- **Solution**: Ensure ErrorLogger.ahk is included and working

### Settings Not Persisting
- **Check**: Write permissions on config directories
- **Solution**: Ensure script has write access to config directories

### Windows Not Closing
- **Check**: Hub's CloseAllDClientWindows function
- **Solution**: Manually close windows if hub fails to close them

---

## Development Notes

### Code Style
- **Minimal Comments**: Only essential comments kept
- **Consistent Naming**: camelCase for variables, PascalCase for functions
- **Error Handling**: Try-catch blocks for file operations
- **Global Variables**: Used sparingly, mostly for GUI references

### Adding New Modules
1. Create module directory
2. Include `ErrorLogger.ahk`
3. Add launch button to DClient Hub
4. Follow existing GUI patterns
5. Use centralized logging
6. Add to window closing list in hub

### Modifying Existing Modules
- **Backup**: Always backup before major changes
- **Test**: Test all affected modules after changes
- **Log**: Use appropriate log level (Error/Warning/Info)
- **Settings**: Update settings documentation if adding new settings

---

## Version History

### Current Version
- **Date**: 2024-01-15 (approximate)
- **Features**: 
  - Centralized error logging
  - HTML, CSS, and JavaScript editors with validation
  - Web server control panel
  - Hub for module management
  - Configuration manager with import/export
  - Backup and restore system
  - Settings persistence
  - Window position saving
  - Always On Top option
  - Edit history tracking

---

## Contact and Support

For issues, questions, or contributions, refer to the project repository or documentation.

---

# Troubleshooting

## Common Issues and Solutions

### DClient Hub Won't Launch

**Symptoms**: 
- Double-clicking `Start.bat` shows error message
- `DClientHub.ahk` won't run

**Possible Causes**:
1. AutoHotkey v2.0 not installed and bundled executables missing
2. Script file corrupted or missing
3. Insufficient permissions

**Solutions**:
- **Install AutoHotkey v2.0**: Download from autohotkey.com and install
- **Check Bundled Executables**: Ensure `AutoHotkey64.exe` or `AutoHotkey32.exe` exist in `Module 13 (Webserve)/subscripts/`
- **Run as Administrator**: Right-click `Start.bat` → Run as administrator
- **Check File Paths**: Ensure all module directories exist and are accessible

### HTML Editor Can't Load Content

**Symptoms**:
- HTML Editor opens but text box is empty
- Error message about missing file

**Possible Causes**:
1. `HTMLContent.ahk` file doesn't exist
2. File permissions issue
3. File format not recognized

**Solutions**:
- **Check File Exists**: Verify `Module 13 (Webserve)/subscripts/HTMLContent.ahk` exists
- **Create File**: If missing, create it with basic HTML content
- **Check Permissions**: Ensure script has read access to the file
- **Verify Format**: Ensure file uses proper AutoHotkey continuation section format

### Web Server Won't Start

**Symptoms**:
- "Start Server" button doesn't work
- Server status stays "Stopped"
- Error messages in logs

**Possible Causes**:
1. Port 8080 already in use
2. Cooldown timer active (10 second wait required)
3. Server already running
4. Missing `www/` directory or permissions

**Solutions**:
- **Wait for Cooldown**: Wait 10 seconds between start/stop operations
- **Check Port**: Verify port 8080 is not used by another application
  - Open Command Prompt: `netstat -ano | findstr :8080`
  - If port in use, close the application using it
- **Check Server Status**: Ensure server isn't already running
- **Check Permissions**: Ensure script can create `www/` directory and write `index.html`
- **Check Logs**: View Module 13 logs for specific error messages

### Errors Not Showing in Error Viewer

**Symptoms**:
- Error Viewer opens but shows "No errors logged yet"
- Errors occur but don't appear in viewer

**Possible Causes**:
1. `error_log.txt` doesn't exist
2. ErrorLogger.ahk not included properly
3. File permissions issue
4. Log file cleared

**Solutions**:
- **Check File Exists**: Verify `Module 11 (Errors)/error_log.txt` exists
- **Check Includes**: Ensure `#Include "ErrorLogger.ahk"` is present in module scripts
- **Check Permissions**: Ensure script has write access to Module 11 directory
- **Trigger an Error**: Perform an action that should log an error to test logging
- **Check Log File**: Manually open `error_log.txt` to see if entries exist

### Settings Not Persisting

**Symptoms**:
- Always On Top checkbox resets on restart
- Window positions not remembered
- Preferences lost

**Possible Causes**:
1. Write permissions on config directories
2. Config files being deleted
3. Settings file corruption

**Solutions**:
- **Check Permissions**: Ensure script has write access to config directories
- **Check Files**: Verify INI files exist in config directories
- **Run as Administrator**: May be needed if running from protected locations
- **Check File Paths**: Ensure config directories can be created/written to

### Windows Not Closing Properly

**Symptoms**:
- Hub closes but other windows remain open
- Error messages when closing

**Possible Causes**:
1. Window titles don't match expected names
2. Windows already closed
3. Process hanging

**Solutions**:
- **Manual Close**: Close windows manually if hub fails
- **Check Window Titles**: Verify window titles match expected names:
    - "HTML Editor"
    - "CSS Editor"
    - "JavaScript Editor"
    - "Web Server Control Panel"
    - "Web Server Control Logs"
    - "DClient Error Viewer"
    - "Developer Module"
    - "Developer Module - Password Required"
    - "Configuration Manager"
    - "Backup Manager"
- **Task Manager**: Use Task Manager to end AutoHotkey processes if stuck
- **Restart**: Restart the application if windows become unresponsive

### Log Viewer Not Showing Colors

**Symptoms**:
- Log entries appear but all same color
- RTF formatting not working

**Possible Causes**:
1. RTF rendering issue
2. Log file format incorrect
3. Display issue

**Solutions**:
- **Refresh Logs**: Click "Refresh" button in log viewer
- **Check Log Format**: Ensure log entries have proper format
- **Restart Viewer**: Close and reopen log viewer window
- **Check RTF**: Verify RTF header is being generated correctly

### HTML Validation Failing Incorrectly

**Symptoms**:
- Valid HTML shows validation errors
- False positive validation failures

**Possible Causes**:
1. HTML validation is basic, not full parser
2. Unusual HTML structure
3. Special characters causing issues

**Solutions**:
- **Check HTML Format**: Ensure proper HTML structure
- **Verify Tags**: Check that opening/closing tags match
- **Check Void Elements**: Self-closing tags should end with `/>`
- **Simplify HTML**: Try simpler HTML to isolate the issue
- **Check Error Message**: Read validation error for specific issue

### Server URL Won't Open in Browser

**Symptoms**:
- Clicking "Open Browser" does nothing
- Browser opens but shows error

**Possible Causes**:
1. Server not running
2. Default browser not set
3. URL format issue

**Solutions**:
- **Check Server Status**: Ensure server is running (status shows "Running")
- **Manual Navigation**: Try navigating to http://localhost:8080 manually
- **Check Browser**: Verify default browser is set in Windows
- **Check Firewall**: Ensure firewall isn't blocking localhost connections

### Module Launch Fails from Hub

**Symptoms**:
- Clicking module button does nothing
- Error message about file not found

**Possible Causes**:
1. Module file path incorrect
2. File doesn't exist
3. AutoHotkey not found

**Solutions**:
- **Check File Paths**: Verify module files exist at expected paths
- **Check Hub Code**: Ensure paths in `DClientHub.ahk` are correct
- **Verify AutoHotkey**: Ensure AutoHotkey v2.0 is installed or bundled executables exist
- **Check Permissions**: Ensure script can execute module files

### Edit History Not Saving

**Symptoms**:
- HTML saves successfully but no history file created
- History files missing

**Possible Causes**:
1. `data/` directory permissions
2. Directory doesn't exist
3. File write failure

**Solutions**:
- **Check Directory**: Verify `Module 12 (HTML)/data/` exists
- **Check Permissions**: Ensure script can create files in data directory
- **Check Logs**: Look for error messages about file creation
- **Manual Creation**: Create `data/` directory manually if needed

### Always On Top Not Working

**Symptoms**:
- Checkbox checked but window not staying on top
- Setting doesn't persist

**Possible Causes**:
1. Settings not saving
2. Window option not applied correctly
3. Another window forcing itself on top

**Solutions**:
- **Check Settings File**: Verify INI file is being written
- **Uncheck and Recheck**: Try unchecking and rechecking the box
- **Restart Module**: Close and reopen the module
- **Check Other Windows**: Other Always On Top windows may override

### Log File Growing Too Large

**Symptoms**:
- Application slows down
- Log file very large (MB+)

**Possible Causes**:
1. Logs accumulating over time
2. No log rotation
3. Verbose logging enabled

**Solutions**:
- **Clear Logs**: Use "Clear Logs" button in log viewer or delete log files manually
- **Regular Maintenance**: Periodically clear old logs
- **Check Log Size**: Monitor log file sizes
- **Archive Logs**: Backup and delete old logs if needed

### Cooldown Timer Issues

**Symptoms**:
- Can't start/stop server immediately
- "Please wait X seconds" message

**Possible Causes**:
1. 10 second cooldown between operations
2. Timer not resetting properly

**Solutions**:
- **Wait 10 Seconds**: This is intentional to prevent rapid start/stop
- **Check Last Action**: Ensure previous action completed
- **Restart Application**: If timer seems stuck, restart the control panel

### Window Position Issues

**Symptoms**:
- Windows open off-screen
- Positions not restoring correctly

**Possible Causes**:
1. Saved positions invalid (monitor changed)
2. Multi-monitor setup changed
3. Settings file corruption

**Solutions**:
- **Delete Settings**: Delete position settings from `settings.ini`
- **Reset Positions**: Let windows open at default positions
- **Manual Positioning**: Drag windows to desired positions
- **Check Monitor Setup**: Ensure monitor configuration matches when positions were saved

## Advanced/Niche Issues

### RTF Callback Memory Leaks

**Symptoms**:
- Application memory usage grows over time
- Log viewer becomes slow after extended use
- System performance degrades

**Possible Causes**:
1. RTF callback functions not being freed properly
2. Buffer memory not released
3. Callback handles accumulating

**Solutions**:
- **Restart Application**: Close and reopen log viewer periodically
- **Clear Logs**: Large log files increase memory usage
- **Check CallbackFree**: Verify `CallbackFree()` is called after RTF operations
- **Monitor Memory**: Use Task Manager to monitor AutoHotkey process memory
- **Limit Log Size**: Keep log files under reasonable size (few MB)

### File Handle Leaks

**Symptoms**:
- "Too many open files" errors
- File operations fail after extended use
- Application becomes unresponsive

**Possible Causes**:
1. File handles not closed properly in error cases
2. Exception handling bypassing file close
3. Multiple file operations without proper cleanup

**Solutions**:
- **Check File Closes**: Ensure all `FileOpen()` calls have matching `Close()`
- **Use Try-Finally**: Wrap file operations in try-finally blocks
- **Restart Application**: Close and restart to release handles
- **Check Error Paths**: Ensure file closes even when errors occur
- **Monitor Handles**: Use Process Explorer to check handle count

### Window Handle Issues

**Symptoms**:
- Windows can't be found by title
- `WinExist()` returns false for visible windows
- Window closing fails silently

**Possible Causes**:
1. Window handles becoming invalid
2. Window titles changing
3. Multiple windows with same title
4. Window destroyed but reference still exists

**Solutions**:
- **Use HWND**: Store window handles instead of relying on titles
- **Check Window State**: Verify window exists before operations
- **Unique Titles**: Ensure each window has unique title
- **Refresh References**: Re-acquire window handles if operations fail
- **Check Window Lifecycle**: Don't use handles after window destroyed

### DLL Loading Failures

**Symptoms**:
- Skin not applying
- Error messages about missing DLLs
- Application runs but UI looks wrong

**Possible Causes**:
1. USkin.dll missing or corrupted
2. Architecture mismatch (32-bit vs 64-bit)
3. DLL dependencies missing
4. Path issues with DLL location

**Solutions**:
- **Check DLL Exists**: Verify `USkin.dll` in `Module 13 (Webserve)/subscripts/image_assets/Styles/`
- **Architecture Match**: Ensure DLL matches AutoHotkey architecture (32/64-bit)
- **Dependencies**: Check if DLL requires Visual C++ redistributables
- **Path Verification**: Ensure full path to DLL is correct
- **Fallback**: Application should work without skinning if DLL fails

### Encoding/Unicode Issues

**Symptoms**:
- Special characters display incorrectly
- HTML content corrupted
- Log entries show garbled text
- File content lost on save

**Possible Causes**:
1. UTF-8 encoding not specified
2. File read/write encoding mismatch
3. BOM (Byte Order Mark) issues
4. Character encoding conversion problems

**Solutions**:
- **Specify UTF-8**: Always use `FileOpen(file, mode, "UTF-8")`
- **Consistent Encoding**: Use UTF-8 for all file operations
- **Check BOM**: Some editors add BOM, may cause issues
- **Test Special Characters**: Test with Unicode characters (emojis, accents)
- **Verify File Encoding**: Check file encoding in text editor

### Path Length Limitations

**Symptoms**:
- File operations fail with long paths
- "Path too long" errors
- Files can't be created in deep directories

**Possible Causes**:
1. Windows MAX_PATH limitation (260 characters)
2. Deep directory nesting
3. Long filenames in path

**Solutions**:
- **Use Short Paths**: Keep directory structure shallow
- **Enable Long Paths**: Enable Windows long path support (Group Policy)
- **Use UNC Paths**: Use `\\?\` prefix for paths over 260 chars
- **Shorten Names**: Use shorter directory/file names
- **Check Path Length**: Monitor total path length

### Concurrent File Access

**Symptoms**:
- "File is being used by another process" errors
- Log entries missing
- Settings not saving

**Possible Causes**:
1. Multiple instances accessing same file
2. File not closed before next access
3. Antivirus scanning files
4. File locks not released

**Solutions**:
- **Retry Logic**: Implement retry with delay for file operations
- **Single Instance**: Use `#SingleInstance Force` to prevent multiple instances
- **File Locking**: Check file locks before operations
- **Close Files**: Ensure files closed before next access
- **Exclude from AV**: Add project directory to antivirus exclusions

### Port Binding Failures

**Symptoms**:
- Server won't start
- "Address already in use" errors
- Port appears available but binding fails

**Possible Causes**:
1. Port in TIME_WAIT state
2. Port reserved by Windows
3. Firewall blocking
4. Multiple bind attempts

**Solutions**:
- **Wait Longer**: Ports in TIME_WAIT take time to release
- **Check Reservations**: Use `netsh interface ipv4 show excludedportrange protocol=tcp`
- **Change Port**: Temporarily use different port
- **Restart Network**: Restart network adapter or computer
- **Check Firewall**: Ensure firewall allows localhost connections

### INI File Corruption

**Symptoms**:
- Settings reset unexpectedly
- INI file unreadable
- Application crashes on startup

**Possible Causes**:
1. File write interrupted
2. Invalid INI format
3. Encoding issues
4. Concurrent writes

**Solutions**:
- **Backup INI**: Keep backup of working INI files
- **Validate Format**: Check INI syntax before reading
- **Atomic Writes**: Write to temp file then rename
- **Error Handling**: Handle INI read errors gracefully
- **Regenerate**: Delete corrupted INI to regenerate defaults

### Hotkey Conflicts

**Symptoms**:
- Hotkeys don't work
- Unexpected actions triggered
- Other applications interfere

**Possible Causes**:
1. Global hotkeys conflict with other apps
2. Hotkeys already registered
3. Modifier key issues
4. System hotkeys override

**Solutions**:
- **Check Conflicts**: Identify which app is using the hotkey
- **Change Hotkeys**: Use different key combinations
- **Use Context**: Make hotkeys context-specific
- **Check Modifiers**: Verify Ctrl/Alt/Shift combinations
- **System Hotkeys**: Avoid Windows system hotkey combinations

### Buffer Overflow in RTF

**Symptoms**:
- Log viewer crashes with large logs
- Memory errors
- RTF content truncated

**Possible Causes**:
1. RTF string too large
2. Buffer size limitations
3. Memory allocation failures

**Solutions**:
- **Limit Log Size**: Keep logs under reasonable size
- **Paginate Display**: Show logs in pages/chunks
- **Clear Old Logs**: Regularly clear or archive old logs
- **Check Buffer Sizes**: Verify buffer allocations are sufficient
- **Error Handling**: Handle memory allocation failures

### Window Message Queue Overflow

**Symptoms**:
- GUI becomes unresponsive
- Window updates delayed
- Messages lost

**Possible Causes**:
1. Too many rapid window updates
2. Message queue full
3. Blocking operations in message handlers

**Solutions**:
- **Throttle Updates**: Limit update frequency
- **Use Timers**: Use SetTimer for periodic updates instead of rapid calls
- **Async Operations**: Move heavy operations off main thread
- **Check Queue**: Monitor message queue size
- **Reduce Updates**: Only update when necessary

### Process Hanging on Exit

**Symptoms**:
- Application won't close
- Process remains in Task Manager
- Resources not released

**Possible Causes**:
1. Timers not stopped
2. File handles open
3. Network connections active
4. Callbacks not freed

**Solutions**:
- **Stop Timers**: Ensure all SetTimer calls stopped
- **Close Files**: Verify all files closed
- **Free Callbacks**: Free all callback handles
- **Clean Shutdown**: Implement proper cleanup sequence
- **Force Kill**: Use Task Manager to end process if stuck

### Thread Safety Issues

**Symptoms**:
- Race conditions
- Data corruption
- Unpredictable behavior
- Crashes under load

**Possible Causes**:
1. Shared variables accessed concurrently
2. No synchronization
3. Callback reentrancy

**Solutions**:
- **Avoid Shared State**: Minimize shared variables
- **Synchronize Access**: Use locks or atomic operations
- **Single Thread**: Keep GUI operations on main thread
- **Test Concurrency**: Test with rapid operations
- **Isolate State**: Keep module state separate

### Network Binding to Wrong Interface

**Symptoms**:
- Server starts but not accessible
- Can't connect from other devices
- Only localhost works

**Possible Causes**:
1. Server bound to wrong IP
2. Firewall blocking external access
3. Network interface selection

**Solutions**:
- **Check Binding**: Verify server binds to correct interface
- **Firewall Rules**: Add firewall exception for port 8080
- **Interface Selection**: Ensure binding to 0.0.0.0 or correct interface
- **Test Locally First**: Verify localhost works before external
- **Check Network**: Verify network adapter is active

### Long Running Process Issues

**Symptoms**:
- Application slows down over time
- Memory usage increases
- Features stop working after hours

**Possible Causes**:
1. Memory leaks
2. Resource accumulation
3. Log file growth
4. Handle leaks

**Solutions**:
- **Monitor Resources**: Track memory and handle usage
- **Periodic Restart**: Restart application periodically
- **Log Rotation**: Implement log rotation/archiving
- **Resource Cleanup**: Clean up resources regularly
- **Profiling**: Use profiling tools to identify leaks

### Skin Library Conflicts

**Symptoms**:
- Multiple skin attempts fail
- Skin partially applies
- Window appearance inconsistent

**Possible Causes**:
1. Multiple skin initialization attempts
2. Skin library state issues
3. Window handle timing

**Solutions**:
- **Single Init**: Initialize skin library once
- **Check State**: Verify skin library state before applying
- **Timing**: Apply skin after window fully created
- **Fallback**: Gracefully handle skin failures
- **Reset State**: Reset skin library state if needed

### Callback Memory Leaks

**Symptoms**:
- Memory usage grows
- Callbacks stop working
- Application becomes unstable

**Possible Causes**:
1. Callbacks not freed
2. Callback handles accumulating
3. Memory not released

**Solutions**:
- **Free Callbacks**: Always call `CallbackFree()` when done
- **Track Callbacks**: Keep track of created callbacks
- **Cleanup**: Free callbacks on window close
- **Monitor Memory**: Watch for memory growth patterns
- **Restart**: Restart application if memory grows too large

## Getting Help

If issues persist:

1. **Check Logs**: Review both Module 13 logs and centralized error log
2. **Verify Versions**: Ensure AutoHotkey v2.0 is installed
3. **Check Permissions**: Ensure script has necessary file system permissions
4. **Isolate Issue**: Try launching modules individually to isolate the problem
5. **Check Documentation**: Review relevant sections of this documentation
6. **File Issues**: Report bugs with log files and error messages attached
7. **Advanced Debugging**: For advanced issues, use Process Monitor, Process Explorer, or AutoHotkey debugger
8. **Memory Profiling**: Use memory profiling tools for memory-related issues
9. **Network Tools**: Use netstat, telnet, or Wireshark for network issues

---

**End of Documentation**
