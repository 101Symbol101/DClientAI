#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

htmlContentPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\HTMLContent.ahk"
logFile := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\logs.txt"
configDir := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config"
configFile := configDir . "\htmleditor_settings.ini"
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
                LogError("HTMLEditor", "LogMessage", SafeGetErrorMessage(err), "Failed after 3 retry attempts")
            } else {
                Sleep(10)
            }
        }
    }
}
currentHTML := ""
try {
    if FileExist(htmlContentPath) {
        fileHandle := FileOpen(htmlContentPath, "r", "UTF-8")
        if fileHandle {
            content := fileHandle.Read()
            fileHandle.Close()
            if RegExMatch(content, "s)htmlContent\s*:=\s*`"`n`n\(`n(.*?)\)`"", &match) {
                currentHTML := match[1]
                LogMessage("HTML Editor: Successfully loaded HTML content from HTMLContent.ahk")
            } else if RegExMatch(content, "s)htmlContent\s*:=\s*`"`n\(`n(.*?)\)`"", &match) {
                currentHTML := match[1]
                LogMessage("HTML Editor: Successfully loaded HTML content from HTMLContent.ahk")
            } else if RegExMatch(content, "htmlContent\s*:=\s*`"([^`"]*)`"", &match) {
                currentHTML := match[1]
                LogMessage("HTML Editor: Successfully loaded HTML content from HTMLContent.ahk")
            } else {
                LogMessage("HTML Editor: HTMLContent.ahk found but content format not recognized")
            }
        }
    } else {
        LogMessage("HTML Editor: HTMLContent.ahk file not found")
    }
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    LogMessage("HTML Editor: ERROR - Error loading HTML content: " . errorMsg)
    LogError("HTMLEditor", "LoadHTMLContent", errorMsg, htmlContentPath)
}

ValidateHTML(html) {
    htmlTrimmed := Trim(html)
    
    if (htmlTrimmed = "") {
        return [false, "HTML content cannot be empty"]
    }
    
    if !RegExMatch(htmlTrimmed, "i)<[^>]+>") {
        return [false, "Invalid HTML: No HTML tags found"]
    }
    
    openTags := []
    tagPattern := "<([/]?)([a-zA-Z][a-zA-Z0-9]*)[^>]*>"
    pos := 1
    while (pos := RegExMatch(htmlTrimmed, tagPattern, &match, pos)) {
        tagName := match[2]
        isClosing := match[1] = "/"
        
        if RegExMatch(match[0], "i)/>$") {
            pos += StrLen(match[0])
            continue
        }
        
        if isClosing {
            found := false
            Loop openTags.Length {
                if (openTags[openTags.Length - A_Index + 1] = tagName) {
                    openTags.RemoveAt(openTags.Length - A_Index + 1)
                    found := true
                    break
                }
            }
            if !found {
                return [false, "Invalid HTML: Unmatched closing tag </" . tagName . ">"]
            }
        } else {
            voidElements := ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]
            if !voidElements.HasValue(tagName) {
                openTags.Push(tagName)
            }
        }
        
        pos += StrLen(match[0])
    }
    
    if (openTags.Length > 0) {
        return [false, "Invalid HTML: Unclosed tag(s): " . openTags[1]]
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
    
    LogMessage("HTML Editor: Loading settings from config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
        LogMessage("HTML Editor: Created config directory")
    }
    
    if FileExist(configFile) {
        try {
            alwaysOnTop := IniRead(configFile, "Window", "AlwaysOnTop", "0")
            alwaysOnTop := (alwaysOnTop = "1")
            LogMessage("HTML Editor: AlwaysOnTop setting loaded - " . (alwaysOnTop ? "enabled" : "disabled"))
        } catch as err {
            alwaysOnTop := false
            errorMsg := SafeGetErrorMessage(err)
            LogMessage("HTML Editor: ERROR - Error reading settings file, using defaults")
            LogError("HTMLEditor", "LoadSettings", errorMsg, configFile)
        }
    } else {
        alwaysOnTop := false
        LogMessage("HTML Editor: Settings file not found, using defaults")
    }
}

SaveSettings() {
    global alwaysOnTop, configFile, configDir
    
    LogMessage("HTML Editor: Saving settings to config file...")
    if !DirExist(configDir) {
        DirCreate(configDir)
    }
    
    try {
        IniWrite(alwaysOnTop ? "1" : "0", configFile, "Window", "AlwaysOnTop")
        LogMessage("HTML Editor: Settings saved successfully - AlwaysOnTop: " . (alwaysOnTop ? "enabled" : "disabled"))
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("HTML Editor: ERROR - Error saving settings: " . errorMsg)
        LogError("HTMLEditor", "SaveSettings", errorMsg, configFile)
    }
}

SaveEditHistory(htmlContent) {
    global dataDir
    
    try {
        if !DirExist(dataDir) {
            DirCreate(dataDir)
            LogMessage("HTML Editor: Created data directory")
        }
        
        timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
        fileName := dataDir . "\" . timestamp . ".txt"
        
        fileHandle := FileOpen(fileName, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(htmlContent)
            fileHandle.Close()
            LogMessage("HTML Editor: Edit saved to data folder: " . timestamp . ".txt")
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogMessage("HTML Editor: ERROR - Failed to save edit history: " . errorMsg)
        LogError("HTMLEditor", "SaveEditHistory", errorMsg, fileName)
    }
}

ToggleAlwaysOnTop(*) {
    global mainGui, alwaysOnTop, alwaysOnTopBtn
    
    alwaysOnTop := !alwaysOnTop
    if alwaysOnTop {
        mainGui.Opt("+AlwaysOnTop")
        alwaysOnTopBtn.Value := 1
        LogMessage("HTML Editor: Always On Top enabled")
    } else {
        mainGui.Opt("-AlwaysOnTop")
        alwaysOnTopBtn.Value := 0
        LogMessage("HTML Editor: Always On Top disabled")
    }
    SaveSettings()
}

DragWindow(*) {
    global mainGui
    PostMessage(0x0112, 0xF012, 0,, mainGui)
}

SendButtonClick(*) {
    global htmlTextBox, htmlContentPath
    
    htmlContent := htmlTextBox.Value
    LogMessage("HTML Editor: Send button clicked - validating HTML content...")
    
    isValid := ValidateHTML(htmlContent)
    if !isValid[1] {
        LogMessage("HTML Editor: ERROR - HTML validation failed: " . isValid[2])
        LogError("HTMLEditor", "ValidateHTML", isValid[2], "HTML validation failed")
        MsgBox("Validation Error: " . isValid[2], "Invalid HTML", 0x10)
        return
    }
    
    LogMessage("HTML Editor: HTML validation passed - updating HTMLContent.ahk...")
    
    try {
        fileContent := "#Requires AutoHotkey v2.0`n"
        fileContent .= "htmlContent := `"`n`n"
        fileContent .= "(`n"
        fileContent .= htmlContent
        fileContent .= "`n)`"`n"
        
        fileHandle := FileOpen(htmlContentPath, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(fileContent)
            fileHandle.Close()
            
            SaveEditHistory(htmlContent)
            
            LogMessage("HTML Editor: Successfully updated HTMLContent.ahk")
            LogImportantMessage("HTMLEditor", "UpdateHTMLContent", "Successfully updated HTMLContent.ahk", htmlContentPath)
            MsgBox("HTML content updated successfully!", "Success", 0x40)
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := "Error updating HTMLContent.ahk: " . SafeGetErrorMessage(err)
        LogMessage("HTML Editor: ERROR - " . errorMsg)
        LogError("HTMLEditor", "UpdateHTMLContent", SafeGetErrorMessage(err), htmlContentPath)
        MsgBox(errorMsg, "Error", 0x10)
    }
}

mainGui := Gui("-Caption", "HTML Editor")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "HTML Editor")
titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

htmlTextBox := mainGui.AddEdit("x15 y" . (titleBarHeight + 20) . " w" . (guiWidth - 30) . " h" . (guiHeight - titleBarHeight - 120) . " VScroll cCCCCCC Background2B2B2B", currentHTML)
htmlTextBox.SetFont("s9", "Consolas")

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

LogMessage("HTML Editor: Window opened and displayed")
LogImportantMessage("HTMLEditor", "ApplicationStart", "HTML Editor window opened")

mainGui.OnEvent("Close", (*) => (LogMessage("HTML Editor: Window closing - saving settings..."), SaveSettings(), LogMessage("HTML Editor: Window closed"), LogImportantMessage("HTMLEditor", "ApplicationClose", "HTML Editor window closed"), ExitApp()))

