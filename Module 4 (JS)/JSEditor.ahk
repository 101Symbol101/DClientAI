#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

jsContentPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\JSContent.ahk"
logFile := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\logs.txt"
configDir := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config"
configFile := configDir . "\jseditor_settings.ini"
dataDir := A_ScriptDir . "\data"

alwaysOnTop := false
guiWidth := 800
guiHeight := 600
titleBarHeight := 32

LogMessage(message) {
    global logFile, configDir
    
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timestamp . "] " . message
    
    Loop 3 {
        try {
            if !DirExist(configDir) {
                DirCreate(configDir)
            }
            
            fileHandle := FileOpen(logFile, "a", "UTF-8")
            if fileHandle {
                fileHandle.Write(logEntry . "`n")
                fileHandle.Close()
                break
            }
        } catch as err {
            if (A_Index = 3) {
                LogError("JSEditor", "LogMessage", SafeGetErrorMessage(err), "Failed after 3 retry attempts")
            } else {
                Sleep(10)
            }
        }
    }
}

currentJS := ""
try {
    if FileExist(jsContentPath) {
        fileHandle := FileOpen(jsContentPath, "r", "UTF-8")
        if fileHandle {
            content := fileHandle.Read()
            fileHandle.Close()
            if RegExMatch(content, "s)jsContent\s*:=\s*`"`n`n\(`n(.*?)\)`"", &match) {
                currentJS := match[1]
                LogMessage("JS Editor: Successfully loaded JS content from JSContent.ahk")
            } else if RegExMatch(content, "s)jsContent\s*:=\s*`"`n\(`n(.*?)\)`"", &match) {
                currentJS := match[1]
                LogMessage("JS Editor: Successfully loaded JS content from JSContent.ahk")
            } else if RegExMatch(content, "jsContent\s*:=\s*`"([^`"]*)`"", &match) {
                currentJS := match[1]
                LogMessage("JS Editor: Successfully loaded JS content from JSContent.ahk")
            } else {
                LogMessage("JS Editor: JSContent.ahk found but content format not recognized")
            }
        }
    } else {
        LogMessage("JS Editor: JSContent.ahk file not found, starting with empty content")
    }
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    LogMessage("JS Editor: ERROR - Error loading JS content: " . errorMsg)
    LogError("JSEditor", "LoadJSContent", errorMsg, jsContentPath)
}

ValidateJS(js) {
    jsTrimmed := Trim(js)
    
    if (jsTrimmed = "") {
        return [false, "JavaScript content cannot be empty"]
    }
    
    openBraces := 0
    openParens := 0
    openBrackets := 0
    pos := 1
    
    while (pos := RegExMatch(jsTrimmed, "[{}()\[\]]", &match, pos)) {
        char := match[0]
        if (char = "{") {
            openBraces++
        } else if (char = "}") {
            openBraces--
            if (openBraces < 0) {
                return [false, "Invalid JavaScript: Unmatched closing brace }"]
            }
        } else if (char = "(") {
            openParens++
        } else if (char = ")") {
            openParens--
            if (openParens < 0) {
                return [false, "Invalid JavaScript: Unmatched closing parenthesis )"]
            }
        } else if (char = "[") {
            openBrackets++
        } else if (char = "]") {
            openBrackets--
            if (openBrackets < 0) {
                return [false, "Invalid JavaScript: Unmatched closing bracket ]"]
            }
        }
        pos += StrLen(match[0])
    }
    
    if (openBraces > 0) {
        return [false, "Invalid JavaScript: Unclosed brace(s)"]
    }
    if (openParens > 0) {
        return [false, "Invalid JavaScript: Unclosed parenthesis/parentheses"]
    }
    if (openBrackets > 0) {
        return [false, "Invalid JavaScript: Unclosed bracket(s)"]
    }
    
    return [true, ""]
}

ApplyDarkTheme(hWnd) {
    try {
        DllCall("SetClassLongPtr", "Ptr", hWnd, "Int", -10, "Ptr", 0)
    } catch {
    }
}

ApplySkin(hWnd := 0) {
    skinPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\image_assets\Styles\Concaved.msstyles"
    uSkinDll := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\image_assets\Styles\USkin.dll"
    
    try {
        if !FileExist(uSkinDll) || !FileExist(skinPath)
            return
        
        hModule := DllCall("LoadLibrary", "Str", uSkinDll, "Ptr")
        if !hModule
            return
        
        try {
            result := DllCall(uSkinDll . "\USkin_Init", "Str", skinPath, "Str", "", "Int")
        } catch {
            try {
                DllCall(uSkinDll . "\USkin_LoadSkin", "Str", skinPath, "Int")
            } catch {
                if hWnd {
                    try {
                        DllCall(uSkinDll . "\USkin_Attach", "Ptr", hWnd, "Int")
                    } catch {
                        try {
                            DllCall("USkin_Init", "Str", skinPath, "Str", "", "Int")
                        } catch {
                        }
                    }
                }
            }
        }
    } catch {
    }
}

LoadSettings() {
    global alwaysOnTop, configFile, configDir
    
    LogMessage("JS Editor: Loading settings from config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
        LogMessage("JS Editor: Created config directory")
    }
    
    if FileExist(configFile) {
        try {
            alwaysOnTop := IniRead(configFile, "Window", "AlwaysOnTop", "0")
            alwaysOnTop := (alwaysOnTop = "1")
            LogMessage("JS Editor: AlwaysOnTop setting loaded - " . (alwaysOnTop ? "enabled" : "disabled"))
        } catch as err {
            alwaysOnTop := false
            errorMsg := SafeGetErrorMessage(err)
            LogMessage("JS Editor: ERROR - Error reading settings file, using defaults")
            LogError("JSEditor", "LoadSettings", errorMsg, configFile)
        }
    } else {
        alwaysOnTop := false
        LogMessage("JS Editor: Settings file not found, using defaults")
    }
}

SaveSettings() {
    global alwaysOnTop, configFile, configDir
    
    LogMessage("JS Editor: Saving settings to config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
    }
    
    try {
        IniWrite(alwaysOnTop ? "1" : "0", configFile, "Window", "AlwaysOnTop")
        LogMessage("JS Editor: Settings saved successfully - AlwaysOnTop: " . (alwaysOnTop ? "enabled" : "disabled"))
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("JS Editor: ERROR - Error saving settings: " . errorMsg)
        LogError("JSEditor", "SaveSettings", errorMsg, configFile)
    }
}

SaveEditHistory(jsContent) {
    global dataDir
    
    try {
        if !DirExist(dataDir) {
            DirCreate(dataDir)
            LogMessage("JS Editor: Created data directory")
        }
        
        timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
        fileName := dataDir . "\" . timestamp . ".js"
        
        fileHandle := FileOpen(fileName, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(jsContent)
            fileHandle.Close()
            LogMessage("JS Editor: Edit saved to data folder: " . timestamp . ".js")
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("JS Editor: ERROR - Failed to save edit history: " . errorMsg)
        LogError("JSEditor", "SaveEditHistory", errorMsg, fileName)
    }
}

ToggleAlwaysOnTop(*) {
    global mainGui, alwaysOnTop, alwaysOnTopBtn
    
    alwaysOnTop := !alwaysOnTop
    if alwaysOnTop {
        mainGui.Opt("+AlwaysOnTop")
        alwaysOnTopBtn.Value := 1
        LogMessage("JS Editor: Always On Top enabled")
    } else {
        mainGui.Opt("-AlwaysOnTop")
        alwaysOnTopBtn.Value := 0
        LogMessage("JS Editor: Always On Top disabled")
    }
    SaveSettings()
}

DragWindow(*) {
    global mainGui
    PostMessage(0x0112, 0xF012, 0,, mainGui)
}

SendButtonClick(*) {
    global jsTextBox, jsContentPath
    
    jsContent := jsTextBox.Value
    LogMessage("JS Editor: Send button clicked - validating JS content...")
    
    isValid := ValidateJS(jsContent)
    if !isValid[1] {
        LogMessage("JS Editor: ERROR - JS validation failed: " . isValid[2])
        LogError("JSEditor", "ValidateJS", isValid[2], "JS validation failed")
        MsgBox("Validation Error: " . isValid[2], "Invalid JavaScript", 0x10)
        return
    }
    
    LogMessage("JS Editor: JS validation passed - updating JSContent.ahk...")
    
    try {
        fileContent := "#Requires AutoHotkey v2.0`n"
        fileContent .= "jsContent := `"`n`n"
        fileContent .= "(`n"
        fileContent .= jsContent
        fileContent .= "`n)`"`n"
        
        fileHandle := FileOpen(jsContentPath, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(fileContent)
            fileHandle.Close()
            
            SaveEditHistory(jsContent)
            
            LogMessage("JS Editor: Successfully updated JSContent.ahk")
            LogImportantMessage("JSEditor", "UpdateJSContent", "Successfully updated JSContent.ahk", jsContentPath)
            MsgBox("JavaScript content updated successfully!", "Success", 0x40)
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := "Error updating JSContent.ahk: " . SafeGetErrorMessage(err)
        LogMessage("JS Editor: ERROR - " . errorMsg)
        LogError("JSEditor", "UpdateJSContent", SafeGetErrorMessage(err), jsContentPath)
        MsgBox(errorMsg, "Error", 0x10)
    }
}

mainGui := Gui("-Caption", "JavaScript Editor")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "JavaScript Editor")
titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

jsTextBox := mainGui.AddEdit("x15 y" . (titleBarHeight + 20) . " w" . (guiWidth - 30) . " h" . (guiHeight - titleBarHeight - 120) . " VScroll cCCCCCC Background2B2B2B", currentJS)
jsTextBox.SetFont("s9", "Consolas")

alwaysOnTopBtn := mainGui.AddCheckbox("x15 y" . (guiHeight - 80) . " w" . (guiWidth - 30) . " h20 c888888", "Always On Top")
alwaysOnTopBtn.SetFont("s9 c888888", "Segoe UI")

buttonWidth := 100
buttonHeight := 32
buttonX := guiWidth - buttonWidth - 15
buttonY := guiHeight - buttonHeight - 15
sendBtn := mainGui.AddButton("x" . buttonX . " y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Send")
sendBtn.SetFont("s9 cFFFFFF", "Segoe UI")
sendBtn.OnEvent("Click", SendButtonClick)

closeBtn := mainGui.Add("Button", "x15 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
closeBtn.OnEvent("Click", (*) => mainGui.Destroy())

LoadSettings()
alwaysOnTopBtn.Value := alwaysOnTop ? 1 : 0
if alwaysOnTop {
    mainGui.Opt("+AlwaysOnTop")
}
alwaysOnTopBtn.OnEvent("Click", ToggleAlwaysOnTop)

mainGui.Show("w" . guiWidth . " h" . guiHeight)
ApplyDarkTheme(mainGui.Hwnd)
ApplySkin(mainGui.Hwnd)

LogMessage("JS Editor: Window opened and displayed")
LogImportantMessage("JSEditor", "ApplicationStart", "JavaScript Editor window opened")

mainGui.OnEvent("Close", (*) => (LogMessage("JS Editor: Window closing - saving settings..."), SaveSettings(), LogMessage("JS Editor: Window closed"), LogImportantMessage("JSEditor", "ApplicationClose", "JavaScript Editor window closed"), ExitApp()))

