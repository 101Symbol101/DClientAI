# DClient Error Handling System

This module contains centralized error handling documentation and utilities for all DClient modules.

## Structure

- **ErrorHandlers.ahk** - Contains all error handling patterns organized by category
- **README.md** - This documentation file

## Error Categories

### 1. File Operation Errors
- File read operations
- File write operations
- File append operations (with retry logic)
- File not found errors

### 2. GUI Operation Errors
- GUI creation failures
- Dark theme application failures
- Window skin application failures

### 3. Settings Operation Errors
- Settings file read failures
- Settings file write failures

### 4. Application Launch Errors
- Application launch failures
- File path validation

### 5. Server Operation Errors
- Server start failures
- Server stop failures

### 6. Logging Operation Errors
- Log deletion failures
- Log file load failures

### 7. HTML Validation Errors
- HTML validation failures

### 8. Initialization Errors
- Variable initialization failures
- Startup log loading failures

### 9. Directory Operation Errors
- Directory creation failures

### 10. Window Position Errors
- Window position save failures
- Window position load failures

## Usage

All error patterns are documented in `ErrorHandlers.ahk` with comments showing:
- Where the error is used
- The exact pattern/code structure
- How errors are handled

## Error Handling Utilities

The module includes utility functions:
- `SafeGetErrorMessage(err)` - Safely extracts error message
- `FormatErrorForLog(context, err)` - Formats error for logging
- `FormatErrorForUser(context, err)` - Formats error for user display

## Notes

- All original error handling code remains in place in their respective modules
- This module serves as documentation and reference for error handling patterns
- Future error handling should follow the patterns documented here

