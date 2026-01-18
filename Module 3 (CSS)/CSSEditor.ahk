#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

cssContentPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\CSSContent.ahk"
logFile := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\logs.txt"
configDir := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config"
configFile := configDir . "\csseditor_settings.ini"
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
                LogError("CSSEditor", "LogMessage", SafeGetErrorMessage(err), "Failed after 3 retry attempts")
            } else {
                Sleep(10)
            }
        }
    }
}

currentCSS := ""
try {
    if FileExist(cssContentPath) {
        fileHandle := FileOpen(cssContentPath, "r", "UTF-8")
        if fileHandle {
            content := fileHandle.Read()
            fileHandle.Close()
            if RegExMatch(content, "s)cssContent\s*:=\s*`"`n`n\(`n(.*?)\)`"", &match) {
                currentCSS := match[1]
                LogMessage("CSS Editor: Successfully loaded CSS content from CSSContent.ahk")
            } else if RegExMatch(content, "s)cssContent\s*:=\s*`"`n\(`n(.*?)\)`"", &match) {
                currentCSS := match[1]
                LogMessage("CSS Editor: Successfully loaded CSS content from CSSContent.ahk")
            } else if RegExMatch(content, "cssContent\s*:=\s*`"([^`"]*)`"", &match) {
                currentCSS := match[1]
                LogMessage("CSS Editor: Successfully loaded CSS content from CSSContent.ahk")
            } else {
                LogMessage("CSS Editor: CSSContent.ahk found but content format not recognized")
            }
        }
    } else {
        LogMessage("CSS Editor: CSSContent.ahk file not found, starting with empty content")
    }
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    LogMessage("CSS Editor: ERROR - Error loading CSS content: " . errorMsg)
    LogError("CSSEditor", "LoadCSSContent", errorMsg, cssContentPath)
}

ValidateCSS(css) {
    cssTrimmed := Trim(css)
    
    if (cssTrimmed = "") {
        return [false, "CSS content cannot be empty"]
    }
    
    if !RegExMatch(cssTrimmed, "[{}:;]") {
        return [false, "Invalid CSS: No CSS rules found"]
    }
    
    openBraces := 0
    pos := 1
    while (pos := RegExMatch(cssTrimmed, "[{}]", &match, pos)) {
        if (match[0] = "{") {
            openBraces++
        } else {
            openBraces--
            if (openBraces < 0) {
                return [false, "Invalid CSS: Unmatched closing brace }"]
            }
        }
        pos += StrLen(match[0])
    }
    
    if (openBraces > 0) {
        return [false, "Invalid CSS: Unclosed brace(s)"]
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
    
    LogMessage("CSS Editor: Loading settings from config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
        LogMessage("CSS Editor: Created config directory")
    }
    
    if FileExist(configFile) {
        try {
            alwaysOnTop := IniRead(configFile, "Window", "AlwaysOnTop", "0")
            alwaysOnTop := (alwaysOnTop = "1")
            LogMessage("CSS Editor: AlwaysOnTop setting loaded - " . (alwaysOnTop ? "enabled" : "disabled"))
        } catch as err {
            alwaysOnTop := false
            errorMsg := SafeGetErrorMessage(err)
            LogMessage("CSS Editor: ERROR - Error reading settings file, using defaults")
            LogError("CSSEditor", "LoadSettings", errorMsg, configFile)
        }
    } else {
        alwaysOnTop := false
        LogMessage("CSS Editor: Settings file not found, using defaults")
    }
}

SaveSettings() {
    global alwaysOnTop, configFile, configDir
    
    LogMessage("CSS Editor: Saving settings to config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
    }
    
    try {
        IniWrite(alwaysOnTop ? "1" : "0", configFile, "Window", "AlwaysOnTop")
        LogMessage("CSS Editor: Settings saved successfully - AlwaysOnTop: " . (alwaysOnTop ? "enabled" : "disabled"))
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("CSS Editor: ERROR - Error saving settings: " . errorMsg)
        LogError("CSSEditor", "SaveSettings", errorMsg, configFile)
    }
}

SaveEditHistory(cssContent) {
    global dataDir
    
    try {
        if !DirExist(dataDir) {
            DirCreate(dataDir)
            LogMessage("CSS Editor: Created data directory")
        }
        
        timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
        fileName := dataDir . "\" . timestamp . ".css"
        
        fileHandle := FileOpen(fileName, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(cssContent)
            fileHandle.Close()
            LogMessage("CSS Editor: Edit saved to data folder: " . timestamp . ".css")
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("CSS Editor: ERROR - Failed to save edit history: " . errorMsg)
        LogError("CSSEditor", "SaveEditHistory", errorMsg, fileName)
    }
}

ToggleAlwaysOnTop(*) {
    global mainGui, alwaysOnTop, alwaysOnTopBtn
    
    alwaysOnTop := !alwaysOnTop
    if alwaysOnTop {
        mainGui.Opt("+AlwaysOnTop")
        alwaysOnTopBtn.Value := 1
        LogMessage("CSS Editor: Always On Top enabled")
    } else {
        mainGui.Opt("-AlwaysOnTop")
        alwaysOnTopBtn.Value := 0
        LogMessage("CSS Editor: Always On Top disabled")
    }
    SaveSettings()
}

DragWindow(*) {
    global mainGui
    PostMessage(0x0112, 0xF012, 0,, mainGui)
}

SendButtonClick(*) {
    global cssTextBox, cssContentPath
    
    cssContent := cssTextBox.Value
    LogMessage("CSS Editor: Send button clicked - validating CSS content...")
    
    isValid := ValidateCSS(cssContent)
    if !isValid[1] {
        LogMessage("CSS Editor: ERROR - CSS validation failed: " . isValid[2])
        LogError("CSSEditor", "ValidateCSS", isValid[2], "CSS validation failed")
        MsgBox("Validation Error: " . isValid[2], "Invalid CSS", 0x10)
        return
    }
    
    LogMessage("CSS Editor: CSS validation passed - updating CSSContent.ahk...")
    
    try {
        fileContent := "#Requires AutoHotkey v2.0`n"
        fileContent .= "cssContent := `"`n`n"
        fileContent .= "(`n"
        fileContent .= cssContent
        fileContent .= "`n)`"`n"
        
        fileHandle := FileOpen(cssContentPath, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(fileContent)
            fileHandle.Close()
            
            SaveEditHistory(cssContent)
            
            LogMessage("CSS Editor: Successfully updated CSSContent.ahk")
            LogImportantMessage("CSSEditor", "UpdateCSSContent", "Successfully updated CSSContent.ahk", cssContentPath)
            MsgBox("CSS content updated successfully!", "Success", 0x40)
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := "Error updating CSSContent.ahk: " . SafeGetErrorMessage(err)
        LogMessage("CSS Editor: ERROR - " . errorMsg)
        LogError("CSSEditor", "UpdateCSSContent", SafeGetErrorMessage(err), cssContentPath)
        MsgBox(errorMsg, "Error", 0x10)
    }
}

mainGui := Gui("-Caption", "CSS Editor")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "CSS Editor")
titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

cssTextBox := mainGui.AddEdit("x15 y" . (titleBarHeight + 20) . " w" . (guiWidth - 30) . " h" . (guiHeight - titleBarHeight - 120) . " VScroll cCCCCCC Background2B2B2B", currentCSS)
cssTextBox.SetFont("s9", "Consolas")

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

LogMessage("CSS Editor: Window opened and displayed")
LogImportantMessage("CSSEditor", "ApplicationStart", "CSS Editor window opened")

mainGui.OnEvent("Close", (*) => (LogMessage("CSS Editor: Window closing - saving settings..."), SaveSettings(), LogMessage("CSS Editor: Window closed"), LogImportantMessage("CSSEditor", "ApplicationClose", "CSS Editor window closed"), ExitApp()))

