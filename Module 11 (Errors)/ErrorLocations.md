# DClient Error Handling Locations

This document provides a quick reference to where each error handling pattern is used across DClient modules.

## Module 0 (Main) - DClientHub.ahk

### Application Launch Errors
- **Line 69-77**: LaunchHTMLEditor() - HTML Editor launch error handling
- **Line 84-92**: LaunchGlobalStart() - GlobalStart launch error handling
- **Line 99-107**: OpenLogs() - Log file open error handling

### GUI Operation Errors
- **Line 18-22**: ApplyDarkTheme() - Dark theme application error handling
- **Line 29-56**: ApplySkin() - Window skin application error handling (multiple fallback attempts)

## Module 12 (HTML) - HTMLEditor.ahk

### File Operation Errors
- **Line 28-49**: LogMessage() - File append with retry logic (3 attempts)
- **Line 54-80**: HTML content loading - File read error handling
- **Line 233-256**: SaveEditHistory() - Edit history file write error handling
- **Line 301-325**: SendButtonClick() - HTMLContent.ahk file write error handling

### Settings Operation Errors
- **Line 198-209**: LoadSettings() - Settings file read error handling
- **Line 221-227**: SaveSettings() - Settings file write error handling

### HTML Validation Errors
- **Line 293-294**: SendButtonClick() - HTML validation failure handling

### GUI Operation Errors
- **Line 146-183**: ApplyDarkTheme() and ApplySkin() - Theme/skin application error handling

## Module 13 (Webserve) - GlobalStart.ahk

### Initialization Errors
- **Line 204-208**: LoadLogsFromFile() at startup - Log loading error handling
- **Line 222-242**: Variable initialization - Variable init error handling
- **Line 250-289**: GUI creation - GUI creation error handling
- **Line 325-335**: Theme/skin application - Theme/skin error handling

### File Operation Errors
- **Line 124-135**: AddLogMessage() - Log file append error handling
- **Line 150-187**: LoadLogsFromFile() - Log file read error handling
- **Line 595-609**: DeleteLogs() - Log file deletion error handling

### Settings Operation Errors
- **Line 631-648**: LoadSettings() - Settings file read error handling
- **Line 682-703**: SaveSettings() - Settings file write error handling

### Server Operation Errors
- **Line 399-445**: StartServer() - Server start error handling
- **Line 474-491**: StopServer() - Server stop error handling

### Window Position Errors
- **Line 711-763**: SaveServerGuiPosition() and SaveLogGuiPosition() - Position save error handling
- **Line 796-830**: LoadServerGuiPosition() and LoadLogGuiPosition() - Position load error handling

### GUI Operation Errors
- **Line 810-865**: ApplyDarkTheme() and ApplySkin() - Theme/skin application error handling (multiple fallback attempts)

## Error Handling Patterns Summary

### Pattern 1: Silent Fail (Optional Features)
- **Used for**: Theme/skin application, window position saving
- **Behavior**: Try to apply, but silently continue if it fails
- **Example**: ApplyDarkTheme(), ApplySkin()

### Pattern 2: Log and Continue
- **Used for**: File operations, settings operations
- **Behavior**: Log error message, use defaults or continue
- **Example**: LoadSettings(), LoadLogsFromFile()

### Pattern 3: Log and Show User
- **Used for**: Critical operations that affect user experience
- **Behavior**: Log error, show message box to user
- **Example**: StartServer(), LaunchHTMLEditor()

### Pattern 4: Retry Logic
- **Used for**: File operations that might fail due to locking
- **Behavior**: Retry up to 3 times with delays
- **Example**: LogMessage() file append

### Pattern 5: Startup Error Collection
- **Used for**: Initialization errors at application start
- **Behavior**: Collect errors in array, display summary at end
- **Example**: GlobalStart.ahk startupErrors array

## Notes

- All error handling code remains in their original locations
- This document serves as a reference for maintenance and debugging
- When adding new error handling, follow the patterns documented in ErrorHandlers.ahk

