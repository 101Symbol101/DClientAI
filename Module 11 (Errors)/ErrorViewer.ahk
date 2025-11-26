#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "ErrorLogger.ahk"

errorLogFile := A_ScriptDir . "\error_log.txt"
configFile := A_ScriptDir . "\errorviewer_settings.ini"
skinPath := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\image_assets\Styles\Concaved.msstyles"
uSkinDll := A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\image_assets\Styles\USkin.dll"

alwaysOnTop := false
guiWidth := 800
guiHeight := 600
titleBarHeight := 32

ApplyDarkTheme(hWnd) {
    try {
        DllCall("SetClassLongPtr", "Ptr", hWnd, "Int", -10, "Ptr", 0)
    } catch {
    }
}

ApplySkin(hWnd := 0) {
    global skinPath, uSkinDll
    
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

LoadErrors() {
    global errorLogFile
    
    errorHistory := ""
    try {
        if FileExist(errorLogFile) {
            fileHandle := FileOpen(errorLogFile, "r", "UTF-8")
            if fileHandle {
                errorHistory := fileHandle.Read()
                fileHandle.Close()
            }
        }
    } catch {
        errorHistory := "Error loading error log file."
    }
    
    return errorHistory
}

ShowClearConfirmation() {
    confirmGui := Gui("-Caption", "Confirm Clear Errors")
    confirmGui.BackColor := "2B2B2B"
    confirmGui.SetFont("s9 cWhite Norm", "Segoe UI")
    
    guiWidth := 400
    guiHeight := 200
    titleBarHeight := 32
    
    ; Title bar
    titleBarBg := confirmGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
    titleBarBg.OnEvent("Click", (*) => PostMessage(0x0112, 0xF012, 0,, confirmGui))
    titleText := confirmGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Confirm Clear Errors")
    titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    
    ; Separator
    separator1 := confirmGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
    separator1.Opt("Background444444")
    
    ; Message
    msgText := confirmGui.AddText("x20 y" . (titleBarHeight + 25) . " w" . (guiWidth - 40) . " h50 cFFFFFF Center BackgroundTrans", "Are you sure you want to clear all errors?`n`nThis action cannot be undone.")
    msgText.SetFont("s9", "Segoe UI")
    
    ; Checkbox
    confirmCheckbox := confirmGui.AddCheckbox("x20 y" . (titleBarHeight + 85) . " w" . (guiWidth - 40) . " h20 c888888", "I understand this action cannot be undone")
    confirmCheckbox.SetFont("s8 c888888", "Segoe UI")
    
    ; Buttons
    buttonY := guiHeight - 50
    buttonWidth := 100
    buttonHeight := 32
    
    yesBtn := confirmGui.AddButton("x" . (guiWidth / 2 - buttonWidth - 10) . " y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Yes")
    yesBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    yesBtn.Enabled := false ; Disabled until checkbox is checked
    
    noBtn := confirmGui.AddButton("x" . (guiWidth / 2 + 10) . " y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "No")
    noBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    
    ; Enable/disable Yes button based on checkbox
    confirmCheckbox.OnEvent("Click", (*) => yesBtn.Enabled := confirmCheckbox.Value)
    
    ; Button handlers
    confirmed := false
    yesBtn.OnEvent("Click", (*) => (confirmed := true, confirmGui.Destroy()))
    noBtn.OnEvent("Click", (*) => confirmGui.Destroy())
    
    ; Show GUI
    confirmGui.Show("w" . guiWidth . " h" . guiHeight)
    ApplyDarkTheme(confirmGui.Hwnd)
    ApplySkin(confirmGui.Hwnd)
    
    ; Wait for GUI to close
    WinWaitClose("ahk_id " . confirmGui.Hwnd)
    
    return confirmed
}

ClearErrors(*) {
    global errorTextBox, errorLogFile
    
    ; Show confirmation GUI
    if !ShowClearConfirmation() {
        return ; User cancelled or didn't check the box
    }
    
    try {
        if FileExist(errorLogFile) {
            FileDelete(errorLogFile)
        }
        errorTextBox.Value := "Error log cleared."
        LogImportantMessage("ErrorViewer", "ClearErrors", "Error log cleared by user")
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        MsgBox("Error clearing log: " . errorMsg, "Error", 0x10)
        LogError("ErrorViewer", "ClearErrors", errorMsg, "")
    }
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

; Refresh errors
RefreshErrors(*) {
    global errorTextBox
    
    errorHistory := LoadErrors()
    if (errorHistory = "") {
        errorTextBox.Value := "No errors logged yet."
    } else {
        errorTextBox.Value := errorHistory
        ; Scroll to top
        DllCall("SendMessage", "Ptr", errorTextBox.Hwnd, "UInt", 0x0115, "Int", 6, "Int", 0, "Int")
        DllCall("SendMessage", "Ptr", errorTextBox.Hwnd, "UInt", 0x00B1, "Int", 0, "Int", 0)
    }
}

mainGui := Gui("-Caption", "DClient Error Viewer")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "DClient Error Viewer")
titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

buttonHeight := 28
buttonY := titleBarHeight + 20
refreshBtn := mainGui.AddButton("x15 y" . buttonY . " w" . ((guiWidth - 30) / 3) . " h" . buttonHeight, "Refresh")
refreshBtn.SetFont("s9 cFFFFFF", "Segoe UI")
refreshBtn.OnEvent("Click", RefreshErrors)

clearBtn := mainGui.AddButton("x" . (15 + (guiWidth - 30) / 3) . " y" . buttonY . " w" . ((guiWidth - 30) / 3) . " h" . buttonHeight, "Clear Errors")
clearBtn.SetFont("s9 cFFFFFF", "Segoe UI")
clearBtn.OnEvent("Click", ClearErrors)

alwaysOnTopBtn := mainGui.AddCheckbox("x" . (15 + 2 * (guiWidth - 30) / 3) . " y" . (buttonY + 4) . " w" . ((guiWidth - 30) / 3) . " h" . buttonHeight . " c888888", "Always On Top")
alwaysOnTopBtn.SetFont("s8 c888888", "Segoe UI")

textBoxY := buttonY + buttonHeight + 15
textBoxHeight := guiHeight - textBoxY - 60
errorTextBox := mainGui.AddEdit("x15 y" . textBoxY . " w" . (guiWidth - 30) . " h" . textBoxHeight . " ReadOnly VScroll cCCCCCC Background2B2B2B", "")
errorTextBox.SetFont("s9", "Consolas")

closeBtn := mainGui.Add("Button", "x15 y" . (guiHeight - 40) . " w" . (guiWidth - 30) . " h" . 32, "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
closeBtn.OnEvent("Click", (*) => mainGui.Destroy())

LoadSettings()
alwaysOnTopBtn.Value := alwaysOnTop ? 1 : 0
if alwaysOnTop {
    mainGui.Opt("+AlwaysOnTop")
}
alwaysOnTopBtn.OnEvent("Click", ToggleAlwaysOnTop)

errorHistory := LoadErrors()
if (errorHistory = "") {
    errorTextBox.Value := "No errors logged yet."
} else {
    errorTextBox.Value := errorHistory
    Sleep(50)
    DllCall("SendMessage", "Ptr", errorTextBox.Hwnd, "UInt", 0x0115, "Int", 6, "Int", 0, "Int")
    DllCall("SendMessage", "Ptr", errorTextBox.Hwnd, "UInt", 0x00B1, "Int", 0, "Int", 0)
}

mainGui.Show("w" . guiWidth . " h" . guiHeight)
ApplyDarkTheme(mainGui.Hwnd)
ApplySkin(mainGui.Hwnd)

LogImportantMessage("ErrorViewer", "ApplicationStart", "Error Viewer opened")

mainGui.OnEvent("Close", (*) => (SaveSettings(), LogImportantMessage("ErrorViewer", "ApplicationClose", "Error Viewer closed"), ExitApp()))

