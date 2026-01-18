#Requires AutoHotkey v2
#SingleInstance Force

try {
    #Include "..\Module 11 (Errors)\ErrorLogger.ahk"
} catch as err {
    MsgBox("Error loading ErrorLogger: " . err.Message, "Error", 0x10)
    ExitApp()
}

PASSWORD_HASH := "abc"

guiWidth := 400
guiHeight := 400
titleBarHeight := 32

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
    global passwordGui
    PostMessage(0x0112, 0xF012, 0,, passwordGui)
}

HashPassword(password) {
    try {
        passwordBytes := Buffer(StrPut(password, "UTF-8"))
        StrPut(password, passwordBytes, "UTF-8")
        passwordLen := StrPut(password, "UTF-8") - 1
        
        hProvPtr := 0
        if !DllCall("advapi32\CryptAcquireContext", "Ptr*", &hProvPtr, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000) {
            errorCode := DllCall("kernel32\GetLastError", "UInt")
            throw Error("Failed to acquire crypto context. Error code: " . errorCode)
        }
        
        hHashPtr := 0
        if !DllCall("advapi32\CryptCreateHash", "Ptr", hProvPtr, "UInt", 0x800C, "Ptr", 0, "UInt", 0, "Ptr*", &hHashPtr) {
            errorCode := DllCall("kernel32\GetLastError", "UInt")
            DllCall("advapi32\CryptReleaseContext", "Ptr", hProvPtr, "UInt", 0)
            throw Error("Failed to create hash. Error code: " . errorCode)
        }
        
        if !DllCall("advapi32\CryptHashData", "Ptr", hHashPtr, "Ptr", passwordBytes.Ptr, "UInt", passwordLen, "UInt", 0) {
            errorCode := DllCall("kernel32\GetLastError", "UInt")
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHashPtr)
            DllCall("advapi32\CryptReleaseContext", "Ptr", hProvPtr, "UInt", 0)
            throw Error("Failed to hash data. Error code: " . errorCode)
        }
        
        hashSizeLen := 4
        hashSizeBuffer := Buffer(4, 0)
        if !DllCall("advapi32\CryptGetHashParam", "Ptr", hHashPtr, "UInt", 4, "Ptr", hashSizeBuffer.Ptr, "UInt*", &hashSizeLen, "UInt", 0) {
            errorCode := DllCall("kernel32\GetLastError", "UInt")
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHashPtr)
            DllCall("advapi32\CryptReleaseContext", "Ptr", hProvPtr, "UInt", 0)
            throw Error("Failed to get hash size. Error code: " . errorCode)
        }
        
        hashLen := NumGet(hashSizeBuffer, 0, "UInt")
        
        hashBuffer := Buffer(hashLen, 0)
        if !DllCall("advapi32\CryptGetHashParam", "Ptr", hHashPtr, "UInt", 2, "Ptr", hashBuffer.Ptr, "UInt*", &hashLen, "UInt", 0) {
            errorCode := DllCall("kernel32\GetLastError", "UInt")
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHashPtr)
            DllCall("advapi32\CryptReleaseContext", "Ptr", hProvPtr, "UInt", 0)
            throw Error("Failed to get hash value. Error code: " . errorCode)
        }
        
        hashHex := ""
        Loop hashLen {
            hashHex .= Format("{:02x}", NumGet(hashBuffer, A_Index - 1, "UChar"))
        }
        
        DllCall("advapi32\CryptDestroyHash", "Ptr", hHashPtr)
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProvPtr, "UInt", 0)
        
        return hashHex
    } catch as err {
        try {
            errorMsg := HasProp(err, "Message") ? err.Message : String(err)
            if IsSet(LogError) {
                LogError("DeveloperModule", "HashPassword", errorMsg, "")
            }
        } catch {
        }
        throw Error("Password hashing failed: " . (HasProp(err, "Message") ? err.Message : String(err)))
    }
}

VerifyPassword(inputPassword) {
    global PASSWORD_HASH
    
    try {
        inputHash := HashPassword(inputPassword)
        return (inputHash = PASSWORD_HASH)
    } catch as err {
        try {
            errorMsg := HasProp(err, "Message") ? err.Message : String(err)
            if IsSet(LogError) {
                LogError("DeveloperModule", "VerifyPassword", errorMsg, "")
            }
        } catch {
        }
        return false
    }
}

ShowPasswordPrompt() {
    global passwordGui, passwordInput, errorText
    
    passwordGui := Gui("-Caption", "Developer Module - Password Required")
    passwordGui.BackColor := "2B2B2B"
    passwordGui.SetFont("s9 cWhite Norm", "Segoe UI")
    
    titleBarBg := passwordGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
    titleBarBg.OnEvent("Click", DragWindow)
    titleText := passwordGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Developer Module")
    titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")
    
    separator1 := passwordGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
    separator1.Opt("Background444444")
    
    infoText := passwordGui.AddText("x20 y" . (titleBarHeight + 30) . " w" . (guiWidth - 40) . " h40 Center BackgroundTrans", "This module is restricted to developers only.`nPlease enter the password to continue.")
    infoText.SetFont("s9 cCCCCCC", "Segoe UI")
    
    passwordInput := passwordGui.AddEdit("x20 y" . (titleBarHeight + 80) . " w" . (guiWidth - 40) . " h30 Password", "")
    passwordInput.SetFont("s10 cFFFFFF", "Segoe UI")
    
    submitBtn := passwordGui.AddButton("x20 y" . (titleBarHeight + 130) . " w" . ((guiWidth - 50) / 2) . " h35", "Submit")
    submitBtn.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    submitBtn.OnEvent("Click", OnPasswordSubmit)
    
    cancelBtn := passwordGui.AddButton("x" . (20 + (guiWidth - 50) / 2 + 10) . " y" . (titleBarHeight + 130) . " w" . ((guiWidth - 50) / 2) . " h35", "Cancel")
    cancelBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    cancelBtn.OnEvent("Click", (*) => passwordGui.Destroy())
    
    errorText := passwordGui.AddText("x20 y" . (titleBarHeight + 180) . " w" . (guiWidth - 40) . " h20 Center BackgroundTrans cFF4444 Hidden", "Incorrect password!")
    errorText.SetFont("s8", "Segoe UI")
    
    infoTextBox := passwordGui.AddEdit("x20 y" . (titleBarHeight + 210) . " w" . (guiWidth - 40) . " h60 Multi VScroll", "")
    infoTextBox.SetFont("s8 c000000", "Segoe UI")
    infoTextBox.Value := "This GUI is not meant to keep people out of the developer module, it's here simply to keep those who do not know how to enter it from editing anything in it as it could possibly break the code or cause harm to the user's device. You can find relevant information on how to open it in the README.md file inside of Module 1 (Developer Only!) or DOCUMENTATION.md starting at line 121 (Module 1 section), lines 243-247 (Accessing Developer Module), and lines 233-241 (Setting Up Password)."
    
    passwordGui.OnEvent("Close", (*) => ExitApp())
    
    passwordGui.Show("w" . guiWidth . " h" . guiHeight)
    ApplyDarkTheme(passwordGui.Hwnd)
    ApplySkin(passwordGui.Hwnd)
    
    passwordInput.Focus()
    passwordInput.OnEvent("Change", (*) => (errorText.Visible := false))
    submitBtn.Opt("+Default")
}

OnPasswordSubmit(*) {
    global passwordGui, passwordInput, errorText
    
    enteredPassword := passwordInput.Value
    
    if VerifyPassword(enteredPassword) {
        passwordGui.Destroy()
        ShowDeveloperModule()
    } else {
        errorText.Visible := true
        passwordInput.Value := ""
        passwordInput.Focus()
    }
}

ShowDeveloperModule() {
    devGui := Gui("-Caption", "Developer Module")
    devGui.BackColor := "2B2B2B"
    devGui.SetFont("s9 cWhite Norm", "Segoe UI")
    
    titleBarBg := devGui.AddText("x0 y0 w400 h" . titleBarHeight . " Background2B2B2B", "")
    titleBarBg.OnEvent("Click", (*) => PostMessage(0x0112, 0xF012, 0,, devGui))
    titleText := devGui.AddText("x0 y12 w400 h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Developer Module")
    titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")
    
    separator1 := devGui.AddText("x10 y" . (titleBarHeight + 10) . " w380 h1", "")
    separator1.Opt("Background444444")
    
    welcomeText := devGui.AddText("x20 y" . (titleBarHeight + 30) . " w360 h200 Center BackgroundTrans", "This is a deprecated version of this section and does not grant access to the usage of the development module. We're sorry for the inconvenience and we hope to see you with our full release.")
    welcomeText.SetFont("s10 cCCCCCC", "Segoe UI")
    
    closeBtn := devGui.AddButton("x20 y250 w360 h35", "OK")
    closeBtn.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    closeBtn.OnEvent("Click", (*) => devGui.Destroy())
    
    devGui.OnEvent("Close", (*) => ExitApp())
    
    devGui.Show("w400 h300")
    ApplyDarkTheme(devGui.Hwnd)
    ApplySkin(devGui.Hwnd)
}

try {
    ShowPasswordPrompt()
} catch as err {
    errorMsg := HasProp(err, "Message") ? err.Message : String(err)
    MsgBox("Error starting Developer Module: " . errorMsg, "Error", 0x10)
    ExitApp()
}

