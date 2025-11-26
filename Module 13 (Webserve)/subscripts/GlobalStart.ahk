#Requires AutoHotKey v2.0
#SingleInstance Force

#Include "lib\WebServe.ahk"
#Include "HTMLContent.ahk"
#Include "..\..\Module 11 (Errors)\ErrorLogger.ahk"

logHistory := ""
logHistoryRTF := ""
logText := ""
startupErrors := []

GetLogColor(message) {
    messageLower := StrLower(message)
    if (InStr(messageLower, "error") || InStr(messageLower, "failed") || InStr(messageLower, "stopped")) {
        return "FF4444"  ; Red
    } else if (InStr(messageLower, "success") || InStr(messageLower, "running") || InStr(messageLower, "started") || InStr(messageLower, "ready")) {
        return "44FF44"  ; Green
    } else if (InStr(messageLower, "warning") || InStr(messageLower, "wait")) {
        return "FFAA44"  ; Orange
    } else if (InStr(messageLower, "=== application") || InStr(messageLower, "=== starting") || InStr(messageLower, "=== stopping")) {
        return "44AAFF"  ; Blue
    } else if (InStr(messageLower, "saving") || InStr(messageLower, "loading") || InStr(messageLower, "creating") || InStr(messageLower, "writing")) {
        return "88AAFF"  ; Light blue
    } else {
        return "CCCCCC"  ; Gray
    }
}

GetRTFHeader() {
    bs := Chr(92)
    header := "{" . bs . "rtf1" . bs . "ansi" . bs . "deff0 {"
    header := header . bs . "fonttbl {" . bs . "f0 Consolas;}} {"
    header := header . bs . "colortbl "
    header := header . bs . "red204" . bs . "green204" . bs . "blue204;"
    header := header . bs . "red68" . bs . "green170" . bs . "blue255;"
    header := header . bs . "red136" . bs . "green170" . bs . "blue255;"
    header := header . bs . "red68" . bs . "green255" . bs . "blue68;"
    header := header . bs . "red255" . bs . "green170" . bs . "blue68;"
    header := header . bs . "red255" . bs . "green68" . bs . "blue68;} "
    header := header . bs . "f0" . bs . "fs16 "
    return header
}

RTFStreamCallback(dwCookie, pbBuff, cb, pcb) {
    dataPtr := NumGet(dwCookie, "Ptr")
    pos := NumGet(dwCookie, 8, "Int")
    size := NumGet(dwCookie, 12, "Int")
    
    if (pos >= size) {
        NumPut("Int", 0, pcb, 0)
        return 0
    }
    
    bytesToCopy := (pos + cb > size) ? (size - pos) : cb
    
    DllCall("RtlMoveMemory", "Ptr", pbBuff, "Ptr", dataPtr + pos, "UInt", bytesToCopy)
    
    NumPut("Int", pos + bytesToCopy, dwCookie, 8, "Int")
    
    NumPut("Int", bytesToCopy, pcb, 0)
    
    return 0
}

SetRichEditRTF(hwnd, rtfText) {
    rtfBytes := Buffer(StrPut(rtfText))
    StrPut(rtfText, rtfBytes)
    rtfSize := rtfBytes.Size - 1
    
    streamData := Buffer(16)
    NumPut("Ptr", rtfBytes.Ptr, streamData, 0)
    NumPut("Int", 0, streamData, 8)
    NumPut("Int", rtfSize, streamData, 12)
    
    streamCallback := CallbackCreate(RTFStreamCallback, "C", 4)
    
    stream := Buffer(24)
    NumPut("Ptr", streamData.Ptr, stream, 0)
    NumPut("UInt", 0, stream, 8)
    NumPut("Ptr", streamCallback, stream, 16)
    
    result := DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x0447, "UInt", 0x0002, "Ptr", stream.Ptr, "Int")
    
    CallbackFree(streamCallback)
    return result
}

FormatLogRTF(timestamp, message, color) {
    timestampEscaped := StrReplace(timestamp, "\", "\\")
    timestampEscaped := StrReplace(timestampEscaped, "{", "\\{")
    timestampEscaped := StrReplace(timestampEscaped, "}", "\\}")
    messageEscaped := StrReplace(message, "\", "\\")
    messageEscaped := StrReplace(messageEscaped, "{", "\\{")
    messageEscaped := StrReplace(messageEscaped, "}", "\\}")
    messageEscaped := StrReplace(messageEscaped, "`n", "\\par ")
    bs := Chr(92)
    return "{" . bs . "color #" . color . " [" . timestampEscaped . "] " . messageEscaped . bs . "par}"
}

AddLogMessage(message) {
    global logText, logHistory, logHistoryRTF, logFile, configDir
    
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timestamp . "] " . message
    color := GetLogColor(message)
    rtfEntry := FormatLogRTF(timestamp, message, color)
    
    if (logHistory != "") {
        logHistory := logEntry . "`n" . logHistory
        logHistoryRTF := rtfEntry . logHistoryRTF
    } else {
        logHistory := logEntry
        logHistoryRTF := rtfEntry
    }
    
    ; Append to log file
    try {
        if !DirExist(configDir) {
            DirCreate(configDir)
        }
        
        file := FileOpen(logFile, "a", "UTF-8")
        if file {
            file.Write(logEntry . "`n")
            file.Close()
        }
    } catch {
    }
    
    ; Update UI if log window is open
    if logText {
        logText.Value := logHistory
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x0115, "Int", 6, "Int", 0, "Int")
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x00B1, "Int", 0, "Int", 0)
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x00B7, "Int", 0, "Int", 0)
    }
}

LoadLogsFromFile() {
    global logHistory, logHistoryRTF, logFile, configDir
    
    try {
        if FileExist(logFile) {
            file := FileOpen(logFile, "r", "UTF-8")
            if file {
                fileContent := file.Read()
                file.Close()
                if (SubStr(fileContent, -1) = "`n") {
                    fileContent := SubStr(fileContent, 1, StrLen(fileContent) - 1)
                }
                logLines := StrSplit(fileContent, "`n")
                reversedLines := []
                Loop logLines.Length {
                    reversedLines.Push(logLines[logLines.Length - A_Index + 1])
                }
                logHistory := ""
                logHistoryRTF := ""
                Loop reversedLines.Length {
                    line := reversedLines[A_Index]
                    if (line != "") {
                        if (A_Index > 1) {
                            logHistory := logHistory . "`n"
                        }
                        logHistory := logHistory . line
                        
                        ; Parse timestamp and message for RTF formatting
                        regex := "^\[([^\]]+)\]\s+(.+)$"
                        if RegExMatch(line, regex, &match) {
                            timestamp := match[1]
                            message := match[2]
                            color := GetLogColor(message)
                            rtfEntry := FormatLogRTF(timestamp, message, color)
                            logHistoryRTF := logHistoryRTF . rtfEntry
                        }
                    }
                }
            }
        }
    } catch {
        logHistory := ""
        logHistoryRTF := ""
    }
}

server := ""
serverRunning := false
serverHost := "localhost"
serverPort := 8080
alwaysOnTop := false
configDir := A_ScriptDir . "\config"
configFile := configDir . "\settings.ini"
logFile := configDir . "\logs.txt"

try {
    LoadLogsFromFile()
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to load logs from file: " . errorMsg)
    LogError("GlobalStart", "LoadLogsFromFile", errorMsg, "Startup initialization")
}
if (logHistory != "") {
    logHistory := "`n" . logHistory
    bs := Chr(92)
    logHistoryRTF := "{" . bs . "color #888888" . bs . "par}" . logHistoryRTF
}
AddLogMessage("=== Application Starting ===")
LogImportantMessage("GlobalStart", "ApplicationStart", "Web Server Control Panel starting")
Sleep(100)
AddLogMessage("Loading variables...")
Sleep(50)

startupErrors := []

try {
    skinPath := A_ScriptDir . "\image_assets\Styles\Concaved.msstyles"
    uSkinDll := A_ScriptDir . "\image_assets\Styles\USkin.dll"
    guiWidth := 240
    guiHeight := 400
    logGuiWidth := 600
    logGuiHeight := 500
    lastActionTime := 0
    cooldownDuration := 10000  ; 10 second cooldown between start/stop actions
    logGui := ""
    serverGuiX := ""
    serverGuiY := ""
    serverGuiW := ""
    serverGuiH := ""
    logGuiX := ""
    logGuiY := ""
    logGuiW := ""
    logGuiH := ""
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to initialize variables: " . errorMsg)
    LogError("GlobalStart", "InitializeVariables", errorMsg, "Startup initialization")
}

AddLogMessage("Variables initialized successfully")
Sleep(100)
AddLogMessage("Creating main GUI window...")
Sleep(50)

try {
    serverGui := Gui("-Caption", "Web Server Control Panel")
    serverGui.BackColor := "2B2B2B" 
    serverGui.SetFont("s9 cWhite Norm", "Segoe UI")
    titleBarHeight := 32
    titleBarBg := serverGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
    titleBarBg.OnEvent("Click", (*) => DragWindow())
    titleText := serverGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Web Server Control Panel")
    titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    serverGui.AddText("x15 y" . (titleBarHeight + 12) . " w" . (guiWidth - 30) . " c888888", "Status:")
    statusText := serverGui.AddText("x15 y" . (titleBarHeight + 30) . " w" . (guiWidth - 30) . " cFF4444", "Stopped")
    statusText.SetFont("s10 Bold", "Segoe UI")
    separator1 := serverGui.AddText("x10 y" . (titleBarHeight + 55) . " w" . (guiWidth - 20) . " h1", "")
    separator1.Opt("Background444444")
    serverGui.AddText("x15 y" . (titleBarHeight + 65) . " w" . (guiWidth - 30) . " c888888", "Address:")
    addressText := serverGui.AddText("x15 y" . (titleBarHeight + 85) . " w" . (guiWidth - 30) . " cFFFFFF", "localhost:8080")
    addressText.SetFont("s8", "Consolas")
    serverGui.AddText("x15 y" . (titleBarHeight + 110) . " w" . (guiWidth - 30) . " c888888", "Port:")
    portText := serverGui.AddText("x15 y" . (titleBarHeight + 130) . " w" . (guiWidth - 30) . " cFFFFFF", String(serverPort))
    portText.SetFont("s8", "Consolas")
    separator2 := serverGui.AddText("x10 y" . (titleBarHeight + 155) . " w" . (guiWidth - 20) . " h1", "")
    separator2.Opt("Background444444")
    startBtn := serverGui.AddButton("x15 y" . (titleBarHeight + 165) . " w" . (guiWidth - 30) . " h32", "Start Server")
    startBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    stopBtn := serverGui.AddButton("x15 y" . (titleBarHeight + 205) . " w" . (guiWidth - 30) . " h32", "Stop Server")
    stopBtn.SetFont("s9 cCCCCCC", "Segoe UI")
    stopBtn.Enabled := false

    openBrowserBtn := serverGui.AddButton("x15 y" . (titleBarHeight + 245) . " w" . ((guiWidth - 30) / 2) . " h32", "Open in Browser")
    openBrowserBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    openBrowserBtn.Enabled := false
    newBtn := serverGui.AddButton("x" . (15 + (guiWidth - 30) / 2) . " y" . (titleBarHeight + 245) . " w" . ((guiWidth - 30) / 2) . " h32", "Logs")
    newBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    separator3 := serverGui.AddText("x10 y" . (titleBarHeight + 285) . " w" . (guiWidth - 20) . " h1", "")
    separator3.Opt("Background444444")
    alwaysOnTopBtn := serverGui.AddCheckbox("x15 y" . (titleBarHeight + 295) . " w" . (guiWidth - 30) . " h20 c888888", "Always On Top")
    closeBtn := serverGui.Add("Button", "x15 y" . (titleBarHeight + 320) . " w" . (guiWidth - 30) . " h28", "Close")
    closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to create GUI: " . errorMsg)
    LogError("GlobalStart", "CreateGUI", errorMsg, "Main server control GUI")
}
AddLogMessage("GUI elements created")
Sleep(100)
AddLogMessage("Loading settings from config file...")
try {
    LoadSettings()
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to load settings: " . errorMsg)
    LogError("GlobalStart", "LoadSettings", errorMsg, "Startup initialization")
}
Sleep(100)
AddLogMessage("Settings loaded successfully")
; Configure Always On Top checkbox
alwaysOnTopBtn.Value := alwaysOnTop ? 1 : 0
if alwaysOnTop {
    serverGui.Opt("+AlwaysOnTop")
}
alwaysOnTopBtn.OnEvent("Click", ToggleAlwaysOnTop)
if !alwaysOnTop {
    serverGui.Opt("-AlwaysOnTop")
}

closeBtn.OnEvent("Click", (*) => serverGui.Destroy())

AddLogMessage("Configuring window position...")
Sleep(50)
if (serverGuiX != "" && serverGuiY != "" && serverGuiW != "" && serverGuiH != "") {
    AddLogMessage("Restoring window position: x" . serverGuiX . " y" . serverGuiY . " w" . serverGuiW . " h" . serverGuiH)
    serverGui.Show("x" . serverGuiX . " y" . serverGuiY . " w" . serverGuiW . " h" . serverGuiH)
} else {
    AddLogMessage("Using default window position")
    serverGui.Show("w" . guiWidth . " h" . guiHeight)
}
Sleep(100)
AddLogMessage("Applying dark theme...")
try {
    ApplyDarkTheme(serverGui.Hwnd)
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to apply dark theme: " . errorMsg)
    LogError("GlobalStart", "ApplyDarkTheme", errorMsg, "Server GUI window")
}
Sleep(50)
AddLogMessage("Applying window skin...")
try {
    ApplySkin(serverGui.Hwnd)
} catch as err {
    errorMsg := SafeGetErrorMessage(err)
    startupErrors.Push("Failed to apply window skin: " . errorMsg)
    LogError("GlobalStart", "ApplySkin", errorMsg, "Server GUI window")
}
Sleep(100)
AddLogMessage("Registering button event handlers...")
startBtn.OnEvent("Click", StartServer)
stopBtn.OnEvent("Click", StopServer)
openBrowserBtn.OnEvent("Click", OpenBrowser)
newBtn.OnEvent("Click", OpenLogGui)
SetTimer(SaveServerGuiPosition, 1000)  ; Save position every second
serverGui.OnEvent("Close", (*) => (SetTimer(SaveServerGuiPosition, 0), AddLogMessage("=== Application Shutting Down ==="), LogImportantMessage("GlobalStart", "ApplicationClose", "Web Server Control Panel shutting down"), Sleep(100), SaveServerGuiPosition(), Sleep(50), AddLogMessage("Saving settings..."), SaveSettings(), Sleep(50), AddLogMessage("Cleaning up resources..."), Sleep(100), AddLogMessage("Application closed"), ExitApp()))
Sleep(50)
AddLogMessage("=== Application Ready ===")
AddLogMessage("Server address: http://" . serverHost . ":" . serverPort)
AddLogMessage("Click 'Start Server' to begin")

if (startupErrors.Length > 0) {
    errorCount := startupErrors.Length
    AddLogMessage("=== Startup completed with " . errorCount . " error(s) ===")
    Loop startupErrors.Length {
        AddLogMessage("ERROR " . A_Index . ": " . startupErrors[A_Index])
    }
} else {
    AddLogMessage("Startup completed with no errors")
}

^q::StopServer()
^r::Reload()

StartServer(*) {
    global server, serverRunning, serverHost, serverPort
    global statusText, addressText, startBtn, stopBtn, openBrowserBtn, logText, logHistory
    global lastActionTime, cooldownDuration
    
    AddLogMessage("=== Starting Server ===")
    Sleep(100)
    
    ; Check cooldown timer
    currentTime := A_TickCount
    timeSinceLastAction := currentTime - lastActionTime
    if (timeSinceLastAction < cooldownDuration) {
        remainingSeconds := Round((cooldownDuration - timeSinceLastAction) / 1000)
        AddLogMessage("Please wait " . remainingSeconds . " seconds before starting again.")
        return
    }
    
    if serverRunning {
        AddLogMessage("Server is already running")
        return
    }
    
    AddLogMessage("Preparing web directory...")
    Sleep(100)
    if !DirExist(A_ScriptDir . "\www") {
        AddLogMessage("Creating www directory...")
        DirCreate(A_ScriptDir . "\www")
        Sleep(50)
    } else {
        AddLogMessage("www directory already exists")
        Sleep(50)
    }
    
    AddLogMessage("Writing index.html file...")
    try {
        FileOpen(A_ScriptDir . "\www\index.html", "w", "UTF-8").Write(htmlContent)
        AddLogMessage("index.html created successfully")
        Sleep(100)
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        statusText.Text := "Error: " . errorMsg
        statusText.Opt("cRed")
        AddLogMessage("Failed to write HTML file: " . errorMsg)
        LogError("GlobalStart", "WriteHTMLFile", errorMsg, A_ScriptDir . "\www\index.html")
        return
    }
    
    AddLogMessage("Initializing web server on " . serverHost . ":" . serverPort . "...")
    Sleep(100)
    server := WebServe(serverPort, serverHost, A_ScriptDir . "\www")
    AddLogMessage("Web server instance created")
    Sleep(100)
    
    ; Register API endpoint
    AddLogMessage("Registering API route: /api/hello")
    server.AddRoute("/api/hello", (url, method) => '{"message": "hi", "timestamp": "' . A_Now . '"}')
    Sleep(50)
    AddLogMessage("API route registered successfully")
    Sleep(100)
    
    AddLogMessage("Starting server...")
    try {
        server.Serve()
        serverRunning := true
        AddLogMessage("Server started successfully")
        Sleep(100)

        ; Update UI to reflect running state
        statusText.Text := "Running"
        statusText.Opt("cGreen")
        addressText.Text := "http://" . serverHost . ":" . serverPort
        startBtn.Enabled := false
        stopBtn.Enabled := true
        openBrowserBtn.Enabled := true
        AddLogMessage("Server is running. Access it at: http://" . serverHost . ":" . serverPort)
        lastActionTime := A_TickCount
    } catch as err {
        serverRunning := false
        errorMsg := "Error: " . (HasProp(err, "Message") ? err.Message : String(err))
        statusText.Text := errorMsg
        statusText.Opt("cRed")
        AddLogMessage("Failed to start server: " . errorMsg)
        MsgBox("Server failed to start:`n`n" . errorMsg . "`n`nPossible causes:`n- Port 8080 already in use`n- Firewall blocking`n- Antivirus blocking", "Server Error", 0x10)
    }
}

; Stops the web server
StopServer(*) {
    global server, serverRunning
    global statusText, startBtn, stopBtn, openBrowserBtn, logText, logHistory
    global lastActionTime, cooldownDuration
    
    AddLogMessage("=== Stopping Server ===")
    Sleep(100)
    
    ; Check cooldown timer
    currentTime := A_TickCount
    timeSinceLastAction := currentTime - lastActionTime
    if (timeSinceLastAction < cooldownDuration) {
        remainingSeconds := Round((cooldownDuration - timeSinceLastAction) / 1000)
        AddLogMessage("Please wait " . remainingSeconds . " seconds before stopping again.")
        return
    }
    
    if !serverRunning {
        AddLogMessage("Server is not running")
        return
    }
    
    AddLogMessage("Stopping server instance...")
    Sleep(100)
    try {
        server.Stop()
        AddLogMessage("Server stopped successfully")
        Sleep(100)
        serverRunning := false
        
        ; Update UI to reflect stopped state
        statusText.Text := "Stopped"
        statusText.Opt("cRed")
        startBtn.Enabled := true
        stopBtn.Enabled := false
        openBrowserBtn.Enabled := false
        AddLogMessage("Server status updated to 'Stopped'")
        Sleep(50)
        AddLogMessage("Click 'Start Server' to begin again")
        lastActionTime := A_TickCount
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        AddLogMessage("Error stopping server: " . errorMsg)
        LogError("GlobalStart", "StopServer", errorMsg, "")
    }
}

OpenBrowser(*) {
    global serverHost, serverPort
    
    AddLogMessage("Opening browser to http://" . serverHost . ":" . serverPort)
    Run("http://" . serverHost . ":" . serverPort)
    Sleep(100)
    AddLogMessage("Browser opened successfully")
}

OpenLogGui(*) {
    global logGui, logText, logHistory, logGuiWidth, logGuiHeight, titleBarHeight, skinPath, uSkinDll, alwaysOnTop
    
    ; Close if already open
    if logGui {
        try {
            if WinExist(logGui.Hwnd) || WinExist("ahk_id " . logGui.Hwnd) || WinExist("Web Server Control Logs") {
                SaveLogGuiPosition()
                logGui.Destroy()
                logGui := ""
                logText := ""
                return
            } else {
                logGui := ""
                logText := ""
            }
        } catch {
            logGui := ""
            logText := ""
        }
    } else {
        if WinExist("Web Server Control Logs") {
            try {
                WinClose("Web Server Control Logs")
                return
            } catch {
            }
        }
    }
    
    logGui := Gui("-Caption", "Web Server Control Logs")
    logGui.BackColor := "2B2B2B"
    logGui.SetFont("s9 cWhite Norm", "Segoe UI")
    
    titleBarBg := logGui.AddText("x0 y0 w" . logGuiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
    titleBarBg.OnEvent("Click", (*) => DragLogWindow())
    titleText := logGui.AddText("x0 y12 w" . logGuiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Web Server Control Logs")
    titleText.SetFont("s9 Bold cFFFFFF", "Segoe UI")
    
    separator1 := logGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (logGuiWidth - 20) . " h1", "")
    separator1.Opt("Background444444")
    
    deleteLogsBtn := logGui.AddButton("x15 y" . (titleBarHeight + 20) . " w" . (logGuiWidth - 30) . " h28", "Delete Logs")
    deleteLogsBtn.SetFont("s9 cFFFFFF", "Segoe UI")
    deleteLogsBtn.OnEvent("Click", DeleteLogs)
    
    logText := logGui.AddEdit("x15 y" . (titleBarHeight + 55) . " w" . (logGuiWidth - 30) . " h" . (logGuiHeight - titleBarHeight - 80) . " ReadOnly VScroll cCCCCCC Background2B2B2B", "")
    logText.SetFont("s9", "Consolas")
    
    if alwaysOnTop {
        logGui.Opt("+AlwaysOnTop")
    }
    
    if (logGuiX != "" && logGuiY != "" && logGuiW != "" && logGuiH != "") {
        savedW := Integer(logGuiW)
        savedH := Integer(logGuiH)
        showWidth := (savedW >= logGuiWidth) ? savedW : logGuiWidth
        showHeight := (savedH >= logGuiHeight) ? savedH : logGuiHeight
        logGui.Show("x" . logGuiX . " y" . logGuiY . " w" . showWidth . " h" . showHeight)
    } else {
        logGui.Show("x0 y0 w" . logGuiWidth . " h" . logGuiHeight)
    }
    ApplyDarkTheme(logGui.Hwnd)
    ApplySkin(logGui.Hwnd)
    
    ; Reload logs from file to get latest entries (including from HTMLEditor)
    LoadLogsFromFile()
    
    if (logHistory != "") {
        logText.Value := logHistory
        Sleep(50)
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x0115, "Int", 6, "Int", 0, "Int")
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x00B1, "Int", 0, "Int", 0)
        DllCall("SendMessage", "Ptr", logText.Hwnd, "UInt", 0x00B7, "Int", 0, "Int", 0)
    }
    
    logGui.OnEvent("Close", (*) => (SaveLogGuiPosition(), logGui := "", logText := ""))
}

; Enables dragging log window by title bar
DragLogWindow(*) {
    global logGui
    PostMessage(0x0112, 0xF012, 0,, logGui)
}

DeleteLogs(*) {
    global logText, logHistory, logHistoryRTF, logFile
    
    try {
        logHistory := ""
        logHistoryRTF := ""
        
        if logText {
            logText.Value := ""
        }
        
        if FileExist(logFile) {
            FileDelete(logFile)
        }
        
        AddLogMessage("Logs cleared and log file deleted")
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        AddLogMessage("Error deleting logs: " . errorMsg)
        LogError("GlobalStart", "DeleteLogs", errorMsg, logFile)
    }
}

LoadSettings() {
    global alwaysOnTop, configFile, configDir
    global serverGuiX, serverGuiY, serverGuiW, serverGuiH
    global logGuiX, logGuiY, logGuiW, logGuiH, guiWidth, guiHeight
    
    if !DirExist(configDir) {
        AddLogMessage("Creating config directory...")
        DirCreate(configDir)
        Sleep(50)
    } else {
        AddLogMessage("Config directory found")
        Sleep(50)
    }
    
    if FileExist(configFile) {
        AddLogMessage("Reading settings file: " . configFile)
        Sleep(50)
        try {
            alwaysOnTop := IniRead(configFile, "Window", "AlwaysOnTop", "0")
            alwaysOnTop := (alwaysOnTop = "1")
            AddLogMessage("AlwaysOnTop setting: " . (alwaysOnTop ? "enabled" : "disabled"))
            Sleep(50)
            
            ; Load window positions
            serverGuiX := IniRead(configFile, "ServerGui", "X", "")
            serverGuiY := IniRead(configFile, "ServerGui", "Y", "")
            serverGuiW := IniRead(configFile, "ServerGui", "W", "")
            serverGuiH := IniRead(configFile, "ServerGui", "H", "")
            
            logGuiX := IniRead(configFile, "LogGui", "X", "")
            logGuiY := IniRead(configFile, "LogGui", "Y", "")
            logGuiW := IniRead(configFile, "LogGui", "W", "")
            logGuiH := IniRead(configFile, "LogGui", "H", "")
        } catch {
            AddLogMessage("Error reading settings file, using defaults")
            alwaysOnTop := false
            serverGuiX := ""
            serverGuiY := ""
            serverGuiW := ""
            serverGuiH := ""
            logGuiX := ""
            logGuiY := ""
            logGuiW := ""
            logGuiH := ""
        }
    } else {
        AddLogMessage("Settings file not found, using defaults")
        alwaysOnTop := false
        serverGuiX := ""
        serverGuiY := ""
        serverGuiW := ""
        serverGuiH := ""
        logGuiX := ""
        logGuiY := ""
        logGuiW := ""
        logGuiH := ""
    }
}

SaveSettings() {
    global alwaysOnTop, configFile, configDir
    global serverGuiX, serverGuiY, serverGuiW, serverGuiH
    global logGuiX, logGuiY, logGuiW, logGuiH
    
    if !DirExist(configDir) {
        DirCreate(configDir)
    }
    try {
        AddLogMessage("Writing AlwaysOnTop setting to config file...")
        IniWrite(alwaysOnTop ? "1" : "0", configFile, "Window", "AlwaysOnTop")
        Sleep(50)
        
        ; Save window positions
        if (serverGuiX != "" && serverGuiY != "" && serverGuiW != "" && serverGuiH != "") {
            IniWrite(serverGuiX, configFile, "ServerGui", "X")
            IniWrite(serverGuiY, configFile, "ServerGui", "Y")
            IniWrite(serverGuiW, configFile, "ServerGui", "W")
            IniWrite(serverGuiH, configFile, "ServerGui", "H")
        }
        
        if (logGuiX != "" && logGuiY != "" && logGuiW != "" && logGuiH != "") {
            IniWrite(logGuiX, configFile, "LogGui", "X")
            IniWrite(logGuiY, configFile, "LogGui", "Y")
            IniWrite(logGuiW, configFile, "LogGui", "W")
            IniWrite(logGuiH, configFile, "LogGui", "H")
        }
        AddLogMessage("Settings saved successfully")
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        AddLogMessage("Error saving settings: " . errorMsg)
        LogError("GlobalStart", "SaveSettings", errorMsg, configFile)
    }
}

; Saves main window position to config
SaveServerGuiPosition(*) {
    global serverGui, serverGuiX, serverGuiY, serverGuiW, serverGuiH, configFile, configDir
    
    try {
        if serverGui {
            WinGetPos(&x, &y, &w, &h, serverGui)
            if (x != "" && y != "" && w != "" && h != "") {
                if (serverGuiX != x || serverGuiY != y || serverGuiW != w || serverGuiH != h) {
                    serverGuiX := x
                    serverGuiY := y
                    serverGuiW := w
                    serverGuiH := h
                    
                    if !DirExist(configDir) {
                        DirCreate(configDir)
                    }
                    if (serverGuiX != "" && serverGuiY != "" && serverGuiW != "" && serverGuiH != "") {
                        IniWrite(serverGuiX, configFile, "ServerGui", "X")
                        IniWrite(serverGuiY, configFile, "ServerGui", "Y")
                        IniWrite(serverGuiW, configFile, "ServerGui", "W")
                        IniWrite(serverGuiH, configFile, "ServerGui", "H")
                    }
                }
            }
        }
    } catch {
    }
}

; Saves log window position to config
SaveLogGuiPosition(*) {
    global logGui, logGuiX, logGuiY, logGuiW, logGuiH, configFile, configDir
    
    try {
        if logGui {
            WinGetPos(&x, &y, &w, &h, logGui)
            if (x != "" && y != "" && w != "" && h != "") {
                if (logGuiX != x || logGuiY != y || logGuiW != w || logGuiH != h) {
                    logGuiX := x
                    logGuiY := y
                    logGuiW := w
                    logGuiH := h
                    
                    if !DirExist(configDir) {
                        DirCreate(configDir)
                    }
                    if (logGuiX != "" && logGuiY != "" && logGuiW != "" && logGuiH != "") {
                        IniWrite(logGuiX, configFile, "LogGui", "X")
                        IniWrite(logGuiY, configFile, "LogGui", "Y")
                        IniWrite(logGuiW, configFile, "LogGui", "W")
                        IniWrite(logGuiH, configFile, "LogGui", "H")
                    }
                }
            }
        }
    } catch {
    }
}


; Toggles Always On Top for both windows
ToggleAlwaysOnTop(*) {
    global serverGui, logGui, alwaysOnTop, alwaysOnTopBtn
    
    alwaysOnTop := !alwaysOnTop
    if alwaysOnTop {
        serverGui.Opt("+AlwaysOnTop")
        alwaysOnTopBtn.Value := 1
        if logGui {
            logGui.Opt("+AlwaysOnTop")
        }
    } else {
        serverGui.Opt("-AlwaysOnTop")
        alwaysOnTopBtn.Value := 0
        if logGui {
            logGui.Opt("-AlwaysOnTop")
        }
    }
    SaveSettings()
}

; Enables dragging main window by title bar
DragWindow(*) {
    PostMessage(0x0112, 0xF012, 0,, "A")
}

MinimizeWindow(*) {
    global serverGui
    try {
        PostMessage(0x0112, 0xF020, 0,, serverGui)
    } catch {
        serverGui.Minimize()
    }
}

CloseWindow(*) {
    SaveSettings()
    ExitApp()
}


StyleTitleBarButtons(minBtn, closeBtn) {
    try {
        minBtn.Opt("Background3B3B3B")
        closeBtn.Opt("Background3B3B3B")
        minHwnd := minBtn.Hwnd
        closeHwnd := closeBtn.Hwnd
        hBrush := DllCall("CreateSolidBrush", "UInt", 0x3B3B3B, "Ptr")
        if minHwnd {
            DllCall("SetClassLongPtr", "Ptr", minHwnd, "Int", -10, "Ptr", hBrush)
        }
        if closeHwnd {
            DllCall("SetClassLongPtr", "Ptr", closeHwnd, "Int", -10, "Ptr", hBrush)
        }
    } catch {
    }
}

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
        
        ; Try multiple USkin initialization methods
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