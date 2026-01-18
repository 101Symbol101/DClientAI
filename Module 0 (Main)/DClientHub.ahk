#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

htmlEditorPath := A_ScriptDir . "\..\Module 12 (HTML)\HTMLEditor.ahk"
cssEditorPath := A_ScriptDir . "\..\Module 3 (CSS)\CSSEditor.ahk"
jsEditorPath := A_ScriptDir . "\..\Module 4 (JS)\JSEditor.ahk"
globalStartPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\GlobalStart.ahk"
logFile := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\logs.txt"
errorViewerPath := A_ScriptDir . "\..\Module 11 (Errors)\ErrorViewer.ahk"
developerModulePath := A_ScriptDir . "\..\Module 1 (Developer Only!)\DeveloperModule.ahk"
configManagerPath := A_ScriptDir . "\..\Module 6 (Config)\ConfigManager.ahk"
backupManagerPath := A_ScriptDir . "\..\Module 10 (Backup)\BackupManager.ahk"
configFile := A_ScriptDir . "\hub_settings.ini"

alwaysOnTop := false
guiWidth := 400
guiHeight := 750
titleBarHeight := 32
buttonHeight := 40
buttonSpacing := 15

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

DragWindow(*) {
    global mainGui
    PostMessage(0x0112, 0xF012, 0,, mainGui)
}

LoadSettings() {
    global alwaysOnTop, configFile
    
    try {
        if FileExist(configFile) {
            alwaysOnTop := IniRead(configFile, "Window", "AlwaysOnTop", "0")
            alwaysOnTop := (alwaysOnTop = "1")
        } else {
            alwaysOnTop := false
        }
    } catch {
        alwaysOnTop := false
    }
}

SaveSettings() {
    global alwaysOnTop, configFile
    
    try {
        IniWrite(alwaysOnTop ? "1" : "0", configFile, "Window", "AlwaysOnTop")
    } catch {
    }
}

ToggleAlwaysOnTop(*) {
    global mainGui, alwaysOnTop, alwaysOnTopBtn
    
    alwaysOnTop := !alwaysOnTop
    if alwaysOnTop {
        mainGui.Opt("+AlwaysOnTop")
        alwaysOnTopBtn.Value := 1
    } else {
        mainGui.Opt("-AlwaysOnTop")
        alwaysOnTopBtn.Value := 0
    }
    SaveSettings()
}

LaunchHTMLEditor(*) {
    global htmlEditorPath
    
    try {
        if FileExist(htmlEditorPath) {
            Run('"' . htmlEditorPath . '"')
        } else {
            LogError("DClientHub", "LaunchHTMLEditor", "File not found", htmlEditorPath)
            MsgBox("HTML Editor not found at: " . htmlEditorPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchHTMLEditor", errorMsg, htmlEditorPath)
        MsgBox("Error launching HTML Editor: " . errorMsg, "Error", 0x10)
    }
}

LaunchCSSEditor(*) {
    global cssEditorPath
    
    try {
        if FileExist(cssEditorPath) {
            Run('"' . cssEditorPath . '"')
        } else {
            LogError("DClientHub", "LaunchCSSEditor", "File not found", cssEditorPath)
            MsgBox("CSS Editor not found at: " . cssEditorPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchCSSEditor", errorMsg, cssEditorPath)
        MsgBox("Error launching CSS Editor: " . errorMsg, "Error", 0x10)
    }
}

LaunchJSEditor(*) {
    global jsEditorPath
    
    try {
        if FileExist(jsEditorPath) {
            Run('"' . jsEditorPath . '"')
        } else {
            LogError("DClientHub", "LaunchJSEditor", "File not found", jsEditorPath)
            MsgBox("JS Editor not found at: " . jsEditorPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchJSEditor", errorMsg, jsEditorPath)
        MsgBox("Error launching JS Editor: " . errorMsg, "Error", 0x10)
    }
}

LaunchGlobalStart(*) {
    global globalStartPath
    
    try {
        if FileExist(globalStartPath) {
            Run('"' . globalStartPath . '"')
        } else {
            LogError("DClientHub", "LaunchGlobalStart", "File not found", globalStartPath)
            MsgBox("GlobalStart not found at: " . globalStartPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchGlobalStart", errorMsg, globalStartPath)
        MsgBox("Error launching GlobalStart: " . errorMsg, "Error", 0x10)
    }
}

OpenLogs(*) {
    global logFile
    
    try {
        if FileExist(logFile) {
            Run('notepad.exe "' . logFile . '"')
        } else {
            MsgBox("Log file not found. Make sure GlobalStart has been run at least once.", "Logs Not Found", 0x40)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "OpenLogs", errorMsg, logFile)
        MsgBox("Error opening logs: " . errorMsg, "Error", 0x10)
    }
}

LaunchErrorViewer(*) {
    global errorViewerPath
    
    try {
        if FileExist(errorViewerPath) {
            Run('"' . errorViewerPath . '"')
        } else {
            LogError("DClientHub", "LaunchErrorViewer", "File not found", errorViewerPath)
            MsgBox("Error Viewer not found at: " . errorViewerPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchErrorViewer", errorMsg, errorViewerPath)
        MsgBox("Error launching Error Viewer: " . errorMsg, "Error", 0x10)
    }
}

LaunchDeveloperModule(*) {
    global developerModulePath
    
    try {
        if FileExist(developerModulePath) {
            Run('"' . developerModulePath . '"')
        } else {
            LogError("DClientHub", "LaunchDeveloperModule", "File not found", developerModulePath)
            MsgBox("Developer Module not found at: " . developerModulePath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchDeveloperModule", errorMsg, developerModulePath)
        MsgBox("Error launching Developer Module: " . errorMsg, "Error", 0x10)
    }
}

LaunchConfigManager(*) {
    global configManagerPath
    
    try {
        if FileExist(configManagerPath) {
            Run('"' . configManagerPath . '"')
        } else {
            LogError("DClientHub", "LaunchConfigManager", "File not found", configManagerPath)
            MsgBox("Config Manager not found at: " . configManagerPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchConfigManager", errorMsg, configManagerPath)
        MsgBox("Error launching Config Manager: " . errorMsg, "Error", 0x10)
    }
}

LaunchBackupManager(*) {
    global backupManagerPath
    
    try {
        if FileExist(backupManagerPath) {
            Run('"' . backupManagerPath . '"')
        } else {
            LogError("DClientHub", "LaunchBackupManager", "File not found", backupManagerPath)
            MsgBox("Backup Manager not found at: " . backupManagerPath, "Error", 0x10)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("DClientHub", "LaunchBackupManager", errorMsg, backupManagerPath)
        MsgBox("Error launching Backup Manager: " . errorMsg, "Error", 0x10)
    }
}

CloseAllDClientWindows() {
    windowTitles := [
        "HTML Editor",
        "CSS Editor",
        "JavaScript Editor",
        "Web Server Control Panel",
        "Web Server Control Logs",
        "DClient Error Viewer",
        "Developer Module",
        "Developer Module - Password Required",
        "Configuration Manager",
        "Backup Manager"
    ]
    
    Loop windowTitles.Length {
        title := windowTitles[A_Index]
        try {
            if WinExist(title) {
                WinClose(title)
                Sleep(200)
                if WinExist(title) {
                    WinKill(title)
                    Sleep(100)
                }
            }
        } catch {
        }
    }
}

mainGui := Gui("-Caption", "DClient Hub")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "DClient Hub")
titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

startY := titleBarHeight + 25
currentY := startY

htmlEditorBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "HTML Editor")
htmlEditorBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
htmlEditorBtn.OnEvent("Click", LaunchHTMLEditor)
currentY += buttonHeight + buttonSpacing

cssEditorBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "CSS Editor")
cssEditorBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
cssEditorBtn.OnEvent("Click", LaunchCSSEditor)
currentY += buttonHeight + buttonSpacing

jsEditorBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "JavaScript Editor")
jsEditorBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
jsEditorBtn.OnEvent("Click", LaunchJSEditor)
currentY += buttonHeight + buttonSpacing

globalStartBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "Web Server Control")
globalStartBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
globalStartBtn.OnEvent("Click", LaunchGlobalStart)
currentY += buttonHeight + buttonSpacing

logsBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "View Logs")
logsBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
logsBtn.OnEvent("Click", OpenLogs)
currentY += buttonHeight + buttonSpacing

errorViewerBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "Error Viewer")
errorViewerBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
errorViewerBtn.OnEvent("Click", LaunchErrorViewer)
currentY += buttonHeight + buttonSpacing

developerModuleBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "Developer Module")
developerModuleBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
developerModuleBtn.OnEvent("Click", LaunchDeveloperModule)
currentY += buttonHeight + buttonSpacing

configManagerBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "Config Manager")
configManagerBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
configManagerBtn.OnEvent("Click", LaunchConfigManager)
currentY += buttonHeight + buttonSpacing

backupManagerBtn := mainGui.AddButton("x20 y" . currentY . " w" . (guiWidth - 40) . " h" . buttonHeight, "Backup Manager")
backupManagerBtn.SetFont("s10 Bold cFFFFFF", "Segoe UI")
backupManagerBtn.OnEvent("Click", LaunchBackupManager)
currentY += buttonHeight + buttonSpacing

separator2 := mainGui.AddText("x10 y" . (currentY + 10) . " w" . (guiWidth - 20) . " h1", "")
separator2.Opt("Background444444")
currentY += 25

alwaysOnTopBtn := mainGui.AddCheckbox("x20 y" . currentY . " w" . (guiWidth - 40) . " h20 c888888", "Always On Top")
alwaysOnTopBtn.SetFont("s8 c888888", "Segoe UI")
currentY += 30

closeBtn := mainGui.Add("Button", "x20 y" . (guiHeight - buttonHeight - 20) . " w" . (guiWidth - 40) . " h" . buttonHeight, "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
closeBtn.OnEvent("Click", (*) => (CloseAllDClientWindows(), mainGui.Destroy()))

LoadSettings()
alwaysOnTopBtn.Value := alwaysOnTop ? 1 : 0
if alwaysOnTop {
    mainGui.Opt("+AlwaysOnTop")
}
alwaysOnTopBtn.OnEvent("Click", ToggleAlwaysOnTop)

mainGui.Show("w" . guiWidth . " h" . guiHeight)
ApplyDarkTheme(mainGui.Hwnd)
ApplySkin(mainGui.Hwnd)

mainGui.OnEvent("Close", (*) => (SaveSettings(), CloseAllDClientWindows(), ExitApp()))

