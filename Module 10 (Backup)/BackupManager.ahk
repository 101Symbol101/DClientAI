#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Module 11 (Errors)\ErrorLogger.ahk"

backupDir := A_ScriptDir . "\backups"
guiWidth := 600
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

GetBackupList() {
    global backupDir
    
    backups := []
    
    if !DirExist(backupDir) {
        return backups
    }
    
    Loop Files, backupDir . "\*", "D" {
        backups.Push({
            name: A_LoopFileName,
            path: A_LoopFileFullPath,
            date: FileGetTime(A_LoopFileFullPath, "M")
        })
    }
    
    backups := SortBackupsByDate(backups)
    return backups
}

SortBackupsByDate(backups) {
    sorted := []
    Loop backups.Length {
        maxIndex := 1
        maxDate := backups[1].date
        Loop backups.Length {
            if (backups[A_Index].date > maxDate) {
                maxDate := backups[A_Index].date
                maxIndex := A_Index
            }
        }
        sorted.Push(backups[maxIndex])
        backups.RemoveAt(maxIndex)
    }
    return sorted
}

RefreshBackupList(*) {
    global backupList, backupListBox
    
    backupList := GetBackupList()
    
    backupListBox.Delete()
    Loop backupList.Length {
        item := backupList[A_Index]
        displayName := item.name . " (" . FormatTime(item.date, "yyyy-MM-dd HH:mm:ss") . ")"
        backupListBox.Add([displayName])
    }
    
    LogImportantMessage("BackupManager", "RefreshBackupList", "Backup list refreshed")
}

CreateBackup(*) {
    global backupDir
    
    try {
        if !DirExist(backupDir) {
            DirCreate(backupDir)
        }
        
        timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
        backupName := "backup_" . timestamp
        backupPath := backupDir . "\" . backupName
        
        DirCreate(backupPath)
        
        itemsToBackup := [
            {source: A_ScriptDir . "\..\Module 0 (Main)\hub_settings.ini", dest: "hub_settings.ini"},
            {source: A_ScriptDir . "\..\Module 11 (Errors)\errorviewer_settings.ini", dest: "errorviewer_settings.ini"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\settings.ini", dest: "webserver_settings.ini"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\htmleditor_settings.ini", dest: "htmleditor_settings.ini"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\csseditor_settings.ini", dest: "csseditor_settings.ini"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\jseditor_settings.ini", dest: "jseditor_settings.ini"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\HTMLContent.ahk", dest: "HTMLContent.ahk"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\CSSContent.ahk", dest: "CSSContent.ahk"},
            {source: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\JSContent.ahk", dest: "JSContent.ahk"}
        ]
        
        copiedCount := 0
        Loop itemsToBackup.Length {
            item := itemsToBackup[A_Index]
            if FileExist(item.source) {
                try {
                    FileCopy(item.source, backupPath . "\" . item.dest, 1)
                    copiedCount++
                } catch {
                }
            }
        }
        
        infoFile := backupPath . "\backup_info.txt"
        infoContent := "DClient Backup`n"
        infoContent .= "Created: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n"
        infoContent .= "Files backed up: " . copiedCount . "`n"
        
        fileHandle := FileOpen(infoFile, "w", "UTF-8")
        if fileHandle {
            fileHandle.Write(infoContent)
            fileHandle.Close()
        }
        
        MsgBox("Backup created successfully!`n`nName: " . backupName . "`nFiles: " . copiedCount, "Backup Complete", 0x40)
        LogImportantMessage("BackupManager", "CreateBackup", "Backup created", backupName)
        RefreshBackupList()
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("BackupManager", "CreateBackup", errorMsg, backupPath)
        MsgBox("Error creating backup: " . errorMsg, "Error", 0x10)
    }
}

RestoreBackup(*) {
    global backupList, backupListBox
    
    selectedIndex := backupListBox.Value
    if (selectedIndex = 0) {
        MsgBox("Please select a backup to restore.", "No Selection", 0x40)
        return
    }
    
    selectedBackup := backupList[selectedIndex]
    
    result := MsgBox("Are you sure you want to restore backup:`n`n" . selectedBackup.name . "`n`nThis will overwrite current settings and content files.", "Restore Backup", 0x31)
    if (result = "IDCANCEL") {
        return
    }
    
    try {
        restoreMap := [
            {source: "hub_settings.ini", dest: A_ScriptDir . "\..\Module 0 (Main)\hub_settings.ini"},
            {source: "errorviewer_settings.ini", dest: A_ScriptDir . "\..\Module 11 (Errors)\errorviewer_settings.ini"},
            {source: "webserver_settings.ini", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\settings.ini"},
            {source: "htmleditor_settings.ini", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\htmleditor_settings.ini"},
            {source: "csseditor_settings.ini", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\csseditor_settings.ini"},
            {source: "jseditor_settings.ini", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\config\jseditor_settings.ini"},
            {source: "HTMLContent.ahk", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\HTMLContent.ahk"},
            {source: "CSSContent.ahk", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\CSSContent.ahk"},
            {source: "JSContent.ahk", dest: A_ScriptDir . "\..\Module 13 (Webserve)\subscripts\JSContent.ahk"}
        ]
        
        restoredCount := 0
        Loop restoreMap.Length {
            item := restoreMap[A_Index]
            sourceFile := selectedBackup.path . "\" . item.source
            if FileExist(sourceFile) {
                try {
                    destDir := RegExReplace(item.dest, "\\[^\\]+$", "")
                    if !DirExist(destDir) {
                        DirCreate(destDir)
                    }
                    FileCopy(sourceFile, item.dest, 1)
                    restoredCount++
                } catch {
                }
            }
        }
        
        MsgBox("Backup restored successfully!`n`nFiles restored: " . restoredCount . "`n`nPlease restart affected modules for changes to take effect.", "Restore Complete", 0x40)
        LogImportantMessage("BackupManager", "RestoreBackup", "Backup restored", selectedBackup.name)
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("BackupManager", "RestoreBackup", errorMsg, selectedBackup.name)
        MsgBox("Error restoring backup: " . errorMsg, "Error", 0x10)
    }
}

DeleteBackup(*) {
    global backupList, backupListBox
    
    selectedIndex := backupListBox.Value
    if (selectedIndex = 0) {
        MsgBox("Please select a backup to delete.", "No Selection", 0x40)
        return
    }
    
    selectedBackup := backupList[selectedIndex]
    
    result := MsgBox("Are you sure you want to delete backup:`n`n" . selectedBackup.name . "`n`nThis action cannot be undone.", "Delete Backup", 0x31)
    if (result = "IDCANCEL") {
        return
    }
    
    try {
        DirDelete(selectedBackup.path, 1)
        MsgBox("Backup deleted successfully.", "Delete Complete", 0x40)
        LogImportantMessage("BackupManager", "DeleteBackup", "Backup deleted", selectedBackup.name)
        RefreshBackupList()
    } catch as err {
        errorMsg := SafeGetErrorMessage(err)
        LogError("BackupManager", "DeleteBackup", errorMsg, selectedBackup.name)
        MsgBox("Error deleting backup: " . errorMsg, "Error", 0x10)
    }
}

mainGui := Gui("-Caption", "Backup Manager")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s9 cWhite Norm", "Segoe UI")

titleBarBg := mainGui.AddText("x0 y0 w" . guiWidth . " h" . titleBarHeight . " Background2B2B2B", "")
titleBarBg.OnEvent("Click", DragWindow)
titleText := mainGui.AddText("x0 y12 w" . guiWidth . " h" . (titleBarHeight - 5) . " Center BackgroundTrans", "Backup Manager")
titleText.SetFont("s10 Bold cFFFFFF", "Segoe UI")

separator1 := mainGui.AddText("x10 y" . (titleBarHeight + 10) . " w" . (guiWidth - 20) . " h1", "")
separator1.Opt("Background444444")

backupListBox := mainGui.AddListBox("x15 y" . (titleBarHeight + 25) . " w" . (guiWidth - 30) . " h" . (guiHeight - titleBarHeight - 150) . " cCCCCCC Background2B2B2B", [])
backupListBox.SetFont("s9", "Segoe UI")

createBtn := mainGui.AddButton("x15 y" . (guiHeight - 110) . " w120 h30", "Create Backup")
createBtn.SetFont("s9 cFFFFFF", "Segoe UI")
createBtn.OnEvent("Click", CreateBackup)

restoreBtn := mainGui.AddButton("x145 y" . (guiHeight - 110) . " w120 h30", "Restore")
restoreBtn.SetFont("s9 cFFFFFF", "Segoe UI")
restoreBtn.OnEvent("Click", RestoreBackup)

deleteBtn := mainGui.AddButton("x275 y" . (guiHeight - 110) . " w120 h30", "Delete")
deleteBtn.SetFont("s9 cFFFFFF", "Segoe UI")
deleteBtn.OnEvent("Click", DeleteBackup)

refreshBtn := mainGui.AddButton("x405 y" . (guiHeight - 110) . " w120 h30", "Refresh")
refreshBtn.SetFont("s9 cFFFFFF", "Segoe UI")
refreshBtn.OnEvent("Click", RefreshBackupList)

closeBtn := mainGui.AddButton("x15 y" . (guiHeight - 70) . " w" . (guiWidth - 30) . " h30", "Close")
closeBtn.SetFont("s9 cFFFFFF", "Segoe UI")
closeBtn.OnEvent("Click", (*) => mainGui.Destroy())

backupList := []
RefreshBackupList()

mainGui.Show("w" . guiWidth . " h" . guiHeight)
ApplyDarkTheme(mainGui.Hwnd)
ApplySkin(mainGui.Hwnd)

LogImportantMessage("BackupManager", "ApplicationStart", "Backup Manager window opened")

mainGui.OnEvent("Close", (*) => (LogImportantMessage("BackupManager", "ApplicationClose", "Backup Manager window closed"), ExitApp()))

