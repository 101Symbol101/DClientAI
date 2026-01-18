#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

configDir := A_ScriptDir . "\config"
configFile := configDir . "\config_manager.ini"
guiWidth := 500
guiHeight := 500
titleBarHeight := 32

alwaysOnTop := false

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

LoadAllSettings() {
    global settingsList
    
    settingsList := []
    
    configFiles := [
        A_ScriptDir . "\..\Module 0 (Main)\hub_settings.ini",
        A_ScriptDir . "\..\Module 11 (Errors)\errorviewer_settings.ini",
        A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\settings.ini",
        A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\htmleditor_settings.ini",
        A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\csseditor_settings.ini",
        A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\jseditor_settings.ini"
    ]
    
    moduleNames := [
        "DClient Hub",
        "Error Viewer",
        "Web Server",
        "HTML Editor",
        "CSS Editor",
        "JS Editor"
    ]
    
    Loop configFiles.Length {
        filePath := configFiles[A_Index]
        moduleName := moduleNames[A_Index]
        
        if FileExist(filePath) {
            try {
                alwaysOnTopValue := IniRead(filePath, "Window", "AlwaysOnTop", "Not Set")
                settingsList.Push({
                    module: moduleName,
                    file: filePath,
                    alwaysOnTop: alwaysOnTopValue
                })
            } catch {
                settingsList.Push({
                    module: moduleName,
                    file: filePath,
                    alwaysOnTop: "Error reading"
                })
            }
        } else {
            settingsList.Push({
                module: moduleName,
                file: filePath,
                alwaysOnTop: "File not found"
            })
        }
    }
}

RefreshSettingsDisplay(*) {
    global settingsList, settingsText
    
    LoadAllSettings()
    
    displayText := ""
    Loop settingsList.Length {
        item := settingsList[A_Index]
        displayText .= item.module . ":`n"
        displayText .= "  Always On Top: " . item.alwaysOnTop . "`n"
        displayText .= "  Config File: " . item.file . "`n`n"
    }
    
    settingsText.Value := displayText
    LogImportantMessage("ConfigManager", "RefreshSettings", "Settings refreshed")
}

ExportSettings(*) {
    global settingsList
    
    try {
        exportPath := A_ScriptDir . "\config_export_" . FormatTime(, "yyyy-MM-dd_HH-mm-ss") . ".txt"
        
        separator := ""
        Loop 60 {
            separator .= "="
        }
        
        exportContent := "DClient Configuration Export`n"
        exportContent .= "Generated: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n`n"
        exportContent .= separator . "`n`n"
        
        Loop settingsList.Length {
            item := settingsList[A_Index]
            exportContent .= "Module: " . item.module . "`n"
            exportContent .= "Config File: " . item.file . "`n"
            exportContent .= "Always On Top: " . item.alwaysOnTop . "`n`n"
            
            if FileExist(item.file) {
                try {
                    fileContent := FileRead(item.file)
                    exportContent .= "File Contents:`n"
                    exportContent .= fileContent . "`n"
                } catch {
                    exportContent .= "Could not read file contents`n"
                }
            }
            exportContent .= separator . "`n`n"
        }
        
        fileHandle := FileOpen(exportPath, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(exportContent)
            fileHandle.Close()
            MsgBox("Settings exported to:`n" . exportPath, "Export Successful", 0x40)
            LogImportantMessage("ConfigManager", "ExportSettings", "Settings exported", exportPath)
        } else {
            throw Error("Could not open file for writing")
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("ConfigManager", "ExportSettings", errorMsg, exportPath)
        MsgBox("Error exporting settings: " . errorMsg, "Error", 0x10)
    }
}

ImportSettings(*) {
    try {
        filePath := FileSelect(1, A_ScriptDir, "Select Configuration Export File", "Text Files (*.txt)")
        if (filePath = "") {
            return
        }
        
        if !FileExist(filePath) {
            MsgBox("Selected file does not exist.", "Error", 0x10)
            return
        }
        
        result := MsgBox("This will overwrite all current configuration files with the imported settings.`n`nContinue?", "Import Settings", 0x31)
        if (result = "IDCANCEL") {
            return
        }
        
        try {
            exportContent := FileRead(filePath, "UTF-8")
        } catch as err {
            errorMsg := SafeGetErrorMessage(err)
            LogError("ConfigManager", "ImportSettings", "Failed to read file: " . errorMsg, filePath)
            MsgBox("Error reading export file: " . errorMsg, "Error", 0x10)
            return
        }
        
        configFiles := [
            A_ScriptDir . "\..\Module 0 (Main)\hub_settings.ini",
            A_ScriptDir . "\..\Module 11 (Errors)\errorviewer_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\htmleditor_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\csseditor_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\jseditor_settings.ini"
        ]
        
        moduleNames := [
            "DClient Hub",
            "Error Viewer",
            "Web Server",
            "HTML Editor",
            "CSS Editor",
            "JS Editor"
        ]
        
        separator := ""
        Loop 60 {
            separator .= "="
        }
        
        restoredCount := 0
        
        sections := StrSplit(exportContent, separator)
        
        Loop configFiles.Length {
            targetFilePath := configFiles[A_Index]
            moduleName := moduleNames[A_Index]
            
            Loop sections.Length {
                section := sections[A_Index]
                
                if InStr(section, "Module: " . moduleName) && InStr(section, "File Contents:") {
                    if RegExMatch(section, "s)File Contents:`n(.*?)$", &match) {
                        extractedContent := Trim(match[1])
                        
                        if (extractedContent != "" && extractedContent != "Could not read file contents") {
                            try {
                                destDir := RegExReplace(targetFilePath, "\\[^\\]+$", "")
                                if !DirExist(destDir) {
                                    DirCreate(destDir)
                                }
                                
                                fileHandle := FileOpen(targetFilePath, "w", "UTF-8")
                                if fileHandle {
                                    fileHandle.Write(extractedContent)
                                    fileHandle.Close()
                                    restoredCount++
                                    break
                                }
                            } catch as err {
                                LogError("ConfigManager", "ImportSettings", "Failed to write " . targetFilePath . ": " . SafeGetErrorMessage(err), "")
                            }
                        }
                    }
                }
            }
        }
        
        if (restoredCount > 0) {
            MsgBox("Settings imported successfully!`n`nRestored " . restoredCount . " configuration file(s).`n`nPlease restart affected modules for changes to take effect.", "Import Complete", 0x40)
            LogImportantMessage("ConfigManager", "ImportSettings", "Settings imported", "Restored " . restoredCount . " files")
            RefreshSettingsDisplay()
        } else {
            MsgBox("No settings were restored.`n`nThe export file may be in an invalid format or does not contain matching configuration data.", "Import Failed", 0x30)
            LogError("ConfigManager", "ImportSettings", "No files restored", filePath)
        }
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("ConfigManager", "ImportSettings", errorMsg, filePath)
        MsgBox("Error importing settings: " . errorMsg, "Error", 0x10)
    }
}

ResetAllSettings(*) {
    result := MsgBox("Are you sure you want to reset all settings to defaults?`n`nThis will delete all configuration files.", "Reset Settings", 0x31)
    if (result = "IDCANCEL") {
        return
    }
    
    try {
        configFiles := [
            A_ScriptDir . "\..\Module 0 (Main)\hub_settings.ini",
            A_ScriptDir . "\..\Module 11 (Errors)\errorviewer_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\htmleditor_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\csseditor_settings.ini",
            A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\jseditor_settings.ini"
        ]
        
        deletedCount := 0
        Loop configFiles.Length {
            filePath := configFiles[A_Index]
            if FileExist(filePath) {
                try {
                    FileDelete(filePath)
                    deletedCount++
                } catch {
                }
            }
        }
        
        MsgBox("Deleted " . deletedCount . " configuration file(s).`n`nAll modules will use default settings on next launch.", "Reset Complete", 0x40)
        LogImportantMessage("ConfigManager", "ResetSettings", "Settings reset", "Deleted " . deletedCount . " files")
        RefreshSettingsDisplay()
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("ConfigManager", "ResetSettings", errorMsg, "")
        MsgBox("Error resetting settings: " . errorMsg, "Error", 0x10)
    }
}

mainGui := Gui("-Caption", "Configuration Manager")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Configuration Manager")
titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

settingsText := mainGui.AddEdit("x15 y" . (titleBarHeight + 25) . " w" . (guiWidth - 30) . " h" . (guiHeight - titleBarHeight - 150) . " VScroll ReadOnly cCCCCCC Background2B2B2B", "")
settingsText.SetFont("s8", "Consolas")

refreshBtn := mainGui.AddButton("x375 y" . (guiHeight - 110) . " w110 h30", "Refresh")
refreshBtn.SetFont("s9 cFFFFFF", "Segoe UI")
refreshBtn.OnEvent("Click", RefreshSettingsDisplay)

exportBtn := mainGui.AddButton("x15 y" . (guiHeight - 110) . " w110 h30", "Export All")
exportBtn.SetFont("s9 cFFFFFF", "Segoe UI")
exportBtn.OnEvent("Click", ExportSettings)

importBtn := mainGui.AddButton("x135 y" . (guiHeight - 110) . " w110 h30", "Import")
importBtn.SetFont("s9 cFFFFFF", "Segoe UI")
importBtn.OnEvent("Click", ImportSettings)

resetBtn := mainGui.AddButton("x255 y" . (guiHeight - 110) . " w110 h30", "Reset All")
resetBtn.SetFont("s9 cFFFFFF", "Segoe UI")
resetBtn.OnEvent("Click", ResetAllSettings)

closeBtn := mainGui.AddButton("x15 y" . (guiHeight - 70) . " w" . (guiWidth - 30) . " h30", "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
closeBtn.OnEvent("Click", (*) => mainGui.Destroy())

LoadAllSettings()
RefreshSettingsDisplay()

mainGui.Show("w" . guiWidth . " h" . guiHeight)
ApplyDarkTheme(mainGui.Hwnd)
ApplySkin(mainGui.Hwnd)

LogImportantMessage("ConfigManager", "ApplicationStart", "Configuration Manager window opened")

mainGui.OnEvent("Close", (*) => (LogImportantMessage("ConfigManager", "ApplicationClose", "Configuration Manager window closed"), ExitApp()))

