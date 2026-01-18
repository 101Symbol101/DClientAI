# JavaScript Editor

Module 4 provides a visual JavaScript editor with validation, history tracking, and integration with the web server.

## Features

- **JavaScript Editing**: Large text area for editing JavaScript content
- **Validation**: Validates JavaScript syntax (checks braces, parentheses, brackets)
- **History Tracking**: Saves each edit as a timestamped file
- **Always On Top**: Option to keep window above other windows
- **Settings Persistence**: Remembers Always On Top preference

## Usage

1. **Launch JavaScript Editor**:
   - Click "JavaScript Editor" button in DClient Hub
   - Or run `StartJSEditor.bat`
   - Or launch `JSEditor.ahk` directly

2. **Edit JavaScript**:
   - JavaScript content loads automatically from `JSContent.ahk` (if exists)
   - Edit JavaScript in the text box
   - Use "Always On Top" checkbox if needed

3. **Save JavaScript**:
   - Click "Send" button
   - JavaScript is validated automatically
   - If valid, saves to `JSContent.ahk` and creates history file
   - If invalid, shows error message

4. **View Edit History**:
   - Navigate to `Module 4 (JS)/data/`
   - Each file is timestamped: `yyyy-MM-dd_HH-mm-ss.js`

## Validation

The JavaScript editor validates:
- Content is not empty
- Braces `{}` are properly matched
- Parentheses `()` are properly matched
- Brackets `[]` are properly matched

## Files

- **JSEditor.ahk** - Main JavaScript editor application
- **StartJSEditor.bat** - Launcher script
- **data/** - Edit history directory (created automatically)

## Configuration

Settings stored in: `Module 13 (Webserve)/subscripts/config/jseditor_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` ("0" or "1")

## Content Storage

JavaScript content is saved to: `Module 13 (Webserve)/subscripts/JSContent.ahk`

This file can be integrated into your web server's HTML output.

