#SingleInstance Force
#Persistent
SetBatchLines, -1

link := "your link here"
EnvGet, appdata, LOCALAPPDATA
rbxPath := appdata . "\Roblox"
logo := A_Temp . "\haze_logo.png"

if !FileExist(logo)
    UrlDownloadToFile, https://haze.wtf/logo.png, %logo%

active := 0
interval := 5000

Gui, +AlwaysOnTop -Caption +Border +HwndhGui +LastFound
Gui, Color, 1F1F1F, FFFFFF 
Gui, Font, s9 cWhite, Segoe UI
Gui, Add, Picture, x10 y5 w25 h25 +BackgroundTrans, %logo%
Gui, Add, Text, x40 y8 w200 h20 +BackgroundTrans gDrag, Roblox Private Server Joiner
Gui, Font, s10 bold
Gui, Add, Text, x+45 y5 w30 h25 cFF5555 +BackgroundTrans gGuiClose Center, X
Gui, Font, s9 normal
Gui, Add, Progress, x0 y35 w320 h1 Background333333 c333333, 100
Gui, Add, Text, x15 y45 cAAAAAA +BackgroundTrans, Private Server Link:
Gui, Add, Edit, x15 y65 w290 h25 vlinkEdit cBlack, %link%
Gui, Add, Text, x15 y100 cAAAAAA +BackgroundTrans, Roblox Folder:
Gui, Add, Edit, x15 y120 w240 h25 vpathEdit cBlack ReadOnly, %rbxPath%
Gui, Add, Button, x260 y119 w45 h27 gSelect, ...
Gui, Font, s8
Gui, Add, Text, x15 y155 w290 h15 vstatus cGray Center +BackgroundTrans, Status: Idle
Gui, Font, s11 bold
Gui, Add, Progress, x15 y175 w290 h40 Disabled Background00AA00 vbtnBg, 0
Gui, Add, Text, x15 y183 w290 h25 BackgroundTrans Center vbtnText gToggle cWhite, START MONITOR
Gui, Show, w320 h230, RBX Monitor
return

Drag:
    PostMessage, 0xA1, 2,,, A
return

Select:
    if (active)
        return
    FileSelectFolder, sel, *%rbxPath%, 3, Select Roblox Folder
    if (sel != "")
        GuiControl,, pathEdit, %sel%
return

Toggle:
    Gui, Submit, NoHide
    if (!active) {
        if !FileExist(pathEdit . "\logs") {
            MsgBox, 16, Error, Log folder not found!
            return
        }
        if (linkEdit = "") {
            MsgBox, 16, Error, Enter a link.
            return
        }
        active := 1
        GuiControl, Disable, linkEdit
        GuiControl, Disable, pathEdit
        GuiControl, +cAA0000 +BackgroundAA0000, btnBg
        GuiControl,, btnText, STOP MONITOR
        GuiControl,, status, Status: Monitoring...
        SetTimer, monitor, %interval%
        gosub, monitor
    } else {
        active := 0
        SetTimer, monitor, Off
        GuiControl, Enable, linkEdit
        GuiControl, Enable, pathEdit
        GuiControl, +c00AA00 +Background00AA00, btnBg
        GuiControl,, btnText, START MONITOR
        GuiControl,, status, Status: Idle
    }
return

GuiClose:
ExitApp

monitor:
    if (!active)
        return
    GuiControl,, status, Status: Checking...
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        GuiControl,, status, Status: Launching...
        Process, Close, RobloxPlayerLauncher.exe
        launch(linkEdit)
        return
    }
    GuiControl,, status, Status: Scanning...
    logFile := getLog(pathEdit . "\logs")
    if (logFile = "")
        return 
    FileRead, logData, %logFile%
    lines := StrSplit(logData, "`n", "`r")
    content := ""
    Loop, 30 {
        idx := lines.MaxIndex() - 30 + A_Index
        if (idx > 0)
            content .= lines[idx] . "`n"
    }
    if (InStr(content, "DisconnectionNotification") || InStr(content, "Connection lost") || InStr(content, "exiting main loop")) {
        GuiControl,, status, Status: Restarting...
        if WinExist("ahk_exe RobloxPlayerBeta.exe") {
            Run, taskkill /F /IM RobloxPlayerBeta.exe,, Hide
            Sleep, 2000
            launch(linkEdit)
        }
    }
    GuiControl,, status, Status: Monitoring (OK)
return

launch(url) {
    Run, %url%
    Sleep, 60000 
    WinMinimize, ahk_exe chrome.exe
    WinMinimize, ahk_exe msedge.exe
}

getLog(dir) {
    t := 0
    f := ""
    Loop, Files, %dir%\*.log, F
    {
        if (A_LoopFileTimeModified > t) {
            t := A_LoopFileTimeModified
            f := A_LoopFileFullPath
        }
    }
    return f
}
