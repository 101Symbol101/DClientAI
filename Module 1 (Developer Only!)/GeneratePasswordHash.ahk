#Requires AutoHotkey v2
#SingleInstance Force

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
        throw Error("Password hashing failed: " . (HasProp(err, "Message") ? err.Message : String(err)))
    }
}

hashGui := Gui("-Caption", "Password Hash Generator")
hashGui.BackColor := "2B2B2B"
hashGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := hashGui.AddText("x0 y0 w400 h32 Background2B2B2B", "")
titleBarBg.OnEvent("Click", (*) => PostMessage(0x0112, 0xF012, 0,, hashGui))
titleText := hashGui.AddText("x0 y12 w400 h20 Center BackgroundTrans", "Password Hash Generator")
titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")

separator1 := hashGui.AddText("x10 y42 w380 h1", "")
separator1.Opt("Background444444")

infoText := hashGui.AddText("x20 y60 w360 h60 Center BackgroundTrans", "Enter your password below.`nThe SHA-256 hash will be generated and displayed.`nCopy the hash to DeveloperModule.ahk")
infoText.SetFont("s9 cCCCCCC", "Segoe UI")

passwordInput := hashGui.AddEdit("x20 y130 w360 h30 Password", "")
passwordInput.SetFont("s10 cFFFFFF", "Segoe UI")

generateBtn := hashGui.AddButton("x20 y170 w360 h35", "Generate Hash")
generateBtn.SetFont("s9 Bold cFFFFFF", "Segoe UI")

hashOutput := hashGui.AddEdit("x20 y220 w360 h80 ReadOnly", "")
hashOutput.SetFont("s9 cFFFFFF", "Consolas")
hashOutput.BackColor := "1E1E1E"

copyBtn := hashGui.AddButton("x20 y310 w360 h35", "Copy Hash to Clipboard")
copyBtn.SetFont("s9 Bold cFFFFFF", "Segoe UI")
copyBtn.Enabled := false

textBox := hashGui.AddEdit("x20 y355 w360 h60 Multi VScroll", "")
textBox.SetFont("s8 c000000", "Segoe UI")
textBox.Value := "This GUI is not meant to keep people out of the developer module, it's here simply to keep those who do not know how to enter it from editing anything in it as it could possibly break the code or cause harm to the user's device. You can find relevant information on how to open it in the README.md file inside of Module 1 (Developer Only!) or DOCUMENTATION.md starting at line 121 (Module 1 section), lines 243-247 (Accessing Developer Module), and lines 233-241 (Setting Up Password)."

closeBtn := hashGui.AddButton("x20 y425 w360 h30", "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")

OnGenerate(*) {
    global passwordInput, hashOutput, copyBtn
    
    password := passwordInput.Value
    if !password {
        MsgBox("Please enter a password first.", "No Password", 0x40)
        return
    }
    
    try {
        hash := HashPassword(password)
        hashOutput.Value := hash
        copyBtn.Enabled := true
        MsgBox("Hash generated successfully!`n`nCopy the hash from the text box below and paste it into DeveloperModule.ahk`n`nReplace the PASSWORD_HASH variable value with this hash.", "Hash Generated", 0x40)
    } catch as err {
        MsgBox("Error generating hash: " . err.Message, "Error", 0x10)
    }
}

OnCopy(*) {
    global hashOutput
    
    hash := hashOutput.Value
    if hash {
        A_Clipboard := hash
        MsgBox("Hash copied to clipboard!`n`nNow paste it into DeveloperModule.ahk as the PASSWORD_HASH value.", "Copied", 0x40)
    }
}

generateBtn.OnEvent("Click", OnGenerate)
copyBtn.OnEvent("Click", OnCopy)
closeBtn.OnEvent("Click", (*) => hashGui.Destroy())

generateBtn.Opt("+Default")
passwordInput.OnEvent("Change", (*) => (copyBtn.Enabled := false))

hashGui.Opt("+AlwaysOnTop")
hashGui.OnEvent("Close", (*) => ExitApp())

try {
    hashGui.Show("w400 h470")
    passwordInput.Focus()
} catch as err {
    errorMsg := HasProp(err, "Message") ? err.Message : String(err)
    MsgBox("Error starting Password Hash Generator: " . errorMsg, "Error", 0x10)
    ExitApp()
}

