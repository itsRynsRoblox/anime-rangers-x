#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

if !(A_IsAdmin || DllCall("GetCommandLine","str")~=" /restart(?!\S)") {
      Try {
        q:=Chr(34)
        if (A_IsCompiled)
          Run "*RunAs " q A_ScriptFullPath q " /restart"
        else
          Run "*RunAs " q A_AhkPath q " /restart " q A_ScriptFullPath q
      }
    ExitApp
}

SendMode "Event"

#Include %A_ScriptDir%\Lib/Image.ahk
#Include %A_ScriptDir%\Lib\Toggles.ahk
#Include %A_ScriptDir%\lib/GUI.ahk
#Include %A_ScriptDir%\lib/GameMango.ahk
#Include %A_ScriptDir%\lib/Functions.ahk
#Include %A_ScriptDir%\lib/Config.ahk
#Include %A_ScriptDir%\Lib\FindText.ahk
#Include %A_ScriptDir%\Lib\OCR-main\Lib\OCR.ahk
#Include %A_ScriptDir%\lib/webhooksettings.ahk