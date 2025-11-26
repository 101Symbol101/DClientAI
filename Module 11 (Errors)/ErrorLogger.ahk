#Requires AutoHotkey v2.0

errorLogDir := A_ScriptDir
errorLogFile := errorLogDir . "\error_log.txt"

InitializeErrorLogger() {
    global errorLogDir
    
    try {
        if !DirExist(errorLogDir) {
            DirCreate(errorLogDir)
        }
    } catch {
    }
}

LogError(moduleName, errorContext, errorMessage, errorDetails := "") {
    global errorLogFile
    
    InitializeErrorLogger()
    
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    entry := "[" . timestamp . "] [ERROR] [" . moduleName . "] " . errorContext . ": " . errorMessage
    if (errorDetails != "") {
        entry .= " | Details: " . errorDetails
    }
    entry .= "`n"
    
    try {
        fileHandle := FileOpen(errorLogFile, "a", "UTF-8")
        if fileHandle {
            fileHandle.Write(entry)
            fileHandle.Close()
        }
    } catch {
    }
}

LogImportantMessage(moduleName, messageContext, message, details := "") {
    global errorLogFile
    
    InitializeErrorLogger()
    
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    entry := "[" . timestamp . "] [INFO] [" . moduleName . "] " . messageContext . ": " . message
    if (details != "") {
        entry .= " | Details: " . details
    }
    entry .= "`n"
    
    try {
        fileHandle := FileOpen(errorLogFile, "a", "UTF-8")
        if fileHandle {
            fileHandle.Write(entry)
            fileHandle.Close()
        }
    } catch {
    }
}

LogWarning(moduleName, warningContext, warningMessage, details := "") {
    global errorLogFile
    
    InitializeErrorLogger()
    
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    entry := "[" . timestamp . "] [WARNING] [" . moduleName . "] " . warningContext . ": " . warningMessage
    if (details != "") {
        entry .= " | Details: " . details
    }
    entry .= "`n"
    
    try {
        fileHandle := FileOpen(errorLogFile, "a", "UTF-8")
        if fileHandle {
            fileHandle.Write(entry)
            fileHandle.Close()
        }
    } catch {
    }
}

SafeGetErrorMessage(err) {
    if HasProp(err, "Message") {
        return err.Message
    } else {
        return String(err)
    }
}

FormatErrorForLog(context, err) {
    return context . ": " . SafeGetErrorMessage(err)
}

FormatErrorForUser(context, err) {
    return context . "`n`nError: " . SafeGetErrorMessage(err)
}

ClearErrorLog() {
    global errorLogFile
    
    try {
        if FileExist(errorLogFile) {
            FileDelete(errorLogFile)
        }
    } catch {
    }
}

GetErrorLog() {
    global errorLogFile
    
    try {
        if FileExist(errorLogFile) {
            fileHandle := FileOpen(errorLogFile, "r", "UTF-8")
            if fileHandle {
                content := fileHandle.Read()
                fileHandle.Close()
                return content
            }
        }
    } catch {
    }
    return ""
}

InitializeErrorLogger()

