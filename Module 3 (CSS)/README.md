# CSS Editor

Module 3 provides a visual CSS editor with validation, history tracking, and integration with the web server.

## Features

- **CSS Editing**: Large text area for editing CSS content
- **Validation**: Validates CSS syntax (checks for braces matching)
- **History Tracking**: Saves each edit as a timestamped file
- **Always On Top**: Option to keep window above other windows
- **Settings Persistence**: Remembers Always On Top preference

## Usage

1. **Launch CSS Editor**:
   - Click "CSS Editor" button in DClient Hub
   - Or run `StartCSSEditor.bat`
   - Or launch `CSSEditor.ahk` directly

2. **Edit CSS**:
   - CSS content loads automatically from `CSSContent.ahk` (if exists)
   - Edit CSS in the text box
   - Use "Always On Top" checkbox if needed

3. **Save CSS**:
   - Click "Send" button
   - CSS is validated automatically
   - If valid, saves to `CSSContent.ahk` and creates history file
   - If invalid, shows error message

4. **View Edit History**:
   - Navigate to `Module 3 (CSS)/data/`
   - Each file is timestamped: `yyyy-MM-dd_HH-mm-ss.css`

## Validation

The CSS editor validates:
- Content is not empty
- Contains CSS rules (braces, colons, semicolons)
- Braces are properly matched

## Files

- **CSSEditor.ahk** - Main CSS editor application
- **StartCSSEditor.bat** - Launcher script
- **data/** - Edit history directory (created automatically)

## Configuration

Settings stored in: `Module 13 (Webserve)/subscripts/config/csseditor_settings.ini`
- Section: `[Window]`
- Key: `AlwaysOnTop` ("0" or "1")

## Content Storage

CSS content is saved to: `Module 13 (Webserve)/subscripts/CSSContent.ahk`

This file can be integrated into your web server's HTML output.

