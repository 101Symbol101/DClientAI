#Requires AutoHotkey v2.0

; ============================================================================
; DCLIENT ERROR HANDLING SYSTEM
; ============================================================================
; This file contains all error handling patterns used across DClient modules.
; Errors are organized by category for easy reference and maintenance.
; ============================================================================

; ============================================================================
; FILE OPERATION ERRORS
; ============================================================================

; Error: File read operation failed
; Used in: HTMLEditor.ahk (loading HTML content), GlobalStart.ahk (loading logs)
; Pattern:
; try {
;     fileHandle := FileOpen(filePath, "r", "UTF-8")
;     if fileHandle {
;         content := fileHandle.Read()
;         fileHandle.Close()
;     }
; } catch as err {
;     LogMessage("ERROR - Error loading file: " . (HasProp(err, "Message") ? err.Message : String(err)))
; }

; Error: File write operation failed
; Used in: HTMLEditor.ahk (saving HTML, edit history), GlobalStart.ahk (saving logs, settings)
; Pattern:
; try {
;     fileHandle := FileOpen(filePath, "w", "UTF-8")
;     if fileHandle {
;         fileHandle.Write(content)
;         fileHandle.Close()
;     } else {
;         throw Error("Could not open file for writing")
;     }
; } catch as err {
;     LogMessage("ERROR - Error writing file: " . (HasProp(err, "Message") ? err.Message : String(err)))
; }

; Error: File append operation failed (with retry logic)
; Used in: HTMLEditor.ahk (logging), GlobalStart.ahk (logging)
; Pattern:
; Loop 3 {
;     try {
;         fileHandle := FileOpen(logFile, "a", "UTF-8")
;         if fileHandle {
;             fileHandle.Write(logEntry . "`n")
;             fileHandle.Close()
;             break
;         }
;     } catch as err {
;         if (A_Index = 3) {
;             ; Last attempt failed
;         } else {
;             Sleep(10) ; Wait before retry
;         }
;     }
; }

; Error: File not found
; Used in: HTMLEditor.ahk, GlobalStart.ahk, DClientHub.ahk
; Pattern:
; if FileExist(filePath) {
;     ; Process file
; } else {
;     MsgBox("File not found at: " . filePath, "Error", 0x10)
; }

; ============================================================================
; GUI OPERATION ERRORS
; ============================================================================

; Error: GUI creation failed
; Used in: GlobalStart.ahk
; Pattern:
; try {
;     serverGui := Gui("-Caption", "Title")
;     ; Add GUI elements
; } catch as err {
;     startupErrors.Push("Failed to create GUI: " . (HasProp(err, "Message") ? err.Message : String(err)))
; }

; Error: Dark theme application failed
; Used in: HTMLEditor.ahk, GlobalStart.ahk, DClientHub.ahk
; Pattern:
; ApplyDarkTheme(hWnd) {
;     try {
;         DllCall("SetClassLongPtr", "Ptr", hWnd, "Int", -10, "Ptr", 0)
;     } catch {
;         ; Silently fail - theme is optional
;     }
; }

; Error: Window skin application failed
; Used in: HTMLEditor.ahk, GlobalStart.ahk, DClientHub.ahk
; Pattern:
; ApplySkin(hWnd := 0) {
;     try {
;         if !FileExist(uSkinDll) || !FileExist(skinPath)
;             return
;         hModule := DllCall("LoadLibrary", "Str", uSkinDll, "Ptr")
;         if !hModule
;             return
;         try {
;             result := DllCall(uSkinDll . "\USkin_Init", "Str", skinPath, "Str", "", "Int")
;         } catch {
;             try {
;                 DllCall(uSkinDll . "\USkin_LoadSkin", "Str", skinPath, "Int")
;             } catch {
;                 if hWnd {
;                     try {
;                         DllCall(uSkinDll . "\USkin_Attach", "Ptr", hWnd, "Int")
;                     } catch {
;                         try {
;                             DllCall("USkin_Init", "Str", skinPath, "Str", "", "Int")
;                         } catch {
;                             ; All skin methods failed - silently continue
;                         }
;                     }
;                 }
;             }
;         }
;     } catch {
;         ; Silently fail - skin is optional
;     }
; }

; ============================================================================
; SETTINGS OPERATION ERRORS
; ============================================================================

; Error: Settings file read failed
; Used in: HTMLEditor.ahk, GlobalStart.ahk
; Pattern:
; LoadSettings() {
;     if FileExist(configFile) {
;         try {
;             settingValue := IniRead(configFile, "Section", "Key", "Default")
;         } catch {
;             ; Use defaults
;             LogMessage("ERROR - Error reading settings file, using defaults")
;         }
;     } else {
;         ; Use defaults
;         LogMessage("Settings file not found, using defaults")
;     }
; }

; Error: Settings file write failed
; Used in: HTMLEditor.ahk, GlobalStart.ahk
; Pattern:
; SaveSettings() {
;     try {
;         IniWrite(settingValue, configFile, "Section", "Key")
;         LogMessage("Settings saved successfully")
;     } catch as err {
;         LogMessage("ERROR - Error saving settings: " . (HasProp(err, "Message") ? err.Message : String(err)))
;     }
; }

; ============================================================================
; APPLICATION LAUNCH ERRORS
; ============================================================================

; Error: Application launch failed
; Used in: DClientHub.ahk
; Pattern:
; LaunchApplication(*) {
;     try {
;         if FileExist(appPath) {
;             Run('"' . appPath . '"')
;         } else {
;             MsgBox("Application not found at: " . appPath, "Error", 0x10)
;         }
;     } catch as err {
;         MsgBox("Error launching application: " . (HasProp(err, "Message") ? err.Message : String(err)), "Error", 0x10)
;     }
; }

; ============================================================================
; SERVER OPERATION ERRORS
; ============================================================================

; Error: Server start failed
; Used in: GlobalStart.ahk
; Pattern:
; StartServer(*) {
;     try {
;         ; Start server logic
;         statusText.Text := "Running"
;         AddLogMessage("Server started successfully")
;     } catch as err {
;         errorMsg := "Error: " . (HasProp(err, "Message") ? err.Message : String(err))
;         statusText.Text := errorMsg
;         AddLogMessage("Failed to start server: " . errorMsg)
;         MsgBox("Server failed to start:`n`n" . errorMsg, "Server Error", 0x10)
;     }
; }

; Error: Server stop failed
; Used in: GlobalStart.ahk
; Pattern:
; StopServer(*) {
;     try {
;         ; Stop server logic
;         AddLogMessage("Server stopped successfully")
;     } catch as err {
;         AddLogMessage("Error stopping server: " . err.Message)
;     }
; }

; ============================================================================
; LOGGING OPERATION ERRORS
; ============================================================================

; Error: Log deletion failed
; Used in: GlobalStart.ahk
; Pattern:
; DeleteLogs(*) {
;     try {
;         logHistory := ""
;         if FileExist(logFile) {
;             FileDelete(logFile)
;         }
;         AddLogMessage("Logs cleared and log file deleted")
;     } catch as err {
;         AddLogMessage("Error deleting logs: " . (HasProp(err, "Message") ? err.Message : String(err)))
;     }
; }

; Error: Log file load failed
; Used in: GlobalStart.ahk
; Pattern:
; LoadLogsFromFile() {
;     try {
;         if FileExist(logFile) {
;             file := FileOpen(logFile, "r", "UTF-8")
;             if file {
;                 fileContent := file.Read()
;                 file.Close()
;                 ; Process logs
;             }
;         }
;     } catch {
;         logHistory := ""
;         LogMessage("Error reading log file")
;     }
; }

; ============================================================================
; HTML VALIDATION ERRORS
; ============================================================================

; Error: HTML validation failed
; Used in: HTMLEditor.ahk
; Pattern:
; ValidateHTML(html) {
;     ; Validation logic
;     if !isValid[1] {
;         LogMessage("ERROR - HTML validation failed: " . isValid[2])
;         MsgBox("Validation Error: " . isValid[2], "Invalid HTML", 0x10)
;         return
;     }
; }

; ============================================================================
; INITIALIZATION ERRORS
; ============================================================================

; Error: Variable initialization failed
; Used in: GlobalStart.ahk
; Pattern:
; try {
;     ; Initialize variables
;     var1 := value1
;     var2 := value2
; } catch as err {
;     startupErrors.Push("Failed to initialize variables: " . (HasProp(err, "Message") ? err.Message : String(err)))
; }

; Error: Log loading failed at startup
; Used in: GlobalStart.ahk
; Pattern:
; try {
;     LoadLogsFromFile()
; } catch as err {
;     startupErrors.Push("Failed to load logs from file: " . (HasProp(err, "Message") ? err.Message : String(err)))
; }

; ============================================================================
; DIRECTORY OPERATION ERRORS
; ============================================================================

; Error: Directory creation failed
; Used in: HTMLEditor.ahk, GlobalStart.ahk
; Pattern:
; if !DirExist(configDir) {
;     try {
;         DirCreate(configDir)
;     } catch {
;         LogMessage("ERROR - Failed to create directory: " . configDir)
;     }
; }

; ============================================================================
; WINDOW POSITION ERRORS
; ============================================================================

; Error: Window position save failed
; Used in: GlobalStart.ahk
; Pattern:
; SaveWindowPosition() {
;     try {
;         ; Get window position and save
;         IniWrite(x, configFile, "Window", "X")
;     } catch {
;         ; Silently fail - position saving is optional
;     }
; }

; Error: Window position load failed
; Used in: GlobalStart.ahk
; Pattern:
; LoadWindowPosition() {
;     try {
;         x := IniRead(configFile, "Window", "X", "")
;         ; Use position if valid
;     } catch {
;         ; Use default position
;     }
; }

; ============================================================================
; ERROR HANDLING UTILITIES
; ============================================================================

; Function to safely get error message
; Used across all modules
SafeGetErrorMessage(err) {
    if HasProp(err, "Message") {
        return err.Message
    } else {
        return String(err)
    }
}

; Function to format error for logging
; Used across all modules
FormatErrorForLog(context, err) {
    return context . ": " . SafeGetErrorMessage(err)
}

; Function to format error for user display
; Used across all modules
FormatErrorForUser(context, err) {
    return context . "`n`nError: " . SafeGetErrorMessage(err)
}

