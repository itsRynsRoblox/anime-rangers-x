#Requires AutoHotkey v2.0
#SingleInstance Force

global scriptInitialized := false

SendMode "Event"

#Include %A_ScriptDir%\Lib\Image.ahk
#Include %A_ScriptDir%\Lib\Toggles.ahk
#Include %A_ScriptDir%\Lib\MapSkips.ahk
#Include %A_ScriptDir%\Lib\GUI.ahk
#Include %A_ScriptDir%\Lib\GameMango.ahk
#Include %A_ScriptDir%\Lib\Functions.ahk
#Include %A_ScriptDir%\Lib\Config.ahk
#Include %A_ScriptDir%\Lib\MapConfig.ahk
#Include %A_ScriptDir%\Lib\FindText.ahk
#Include %A_ScriptDir%\Lib\OCR-main\Lib\OCR.ahk
#Include %A_ScriptDir%\Lib\webhooksettings.ahk
#Include %A_ScriptDir%\Lib\UpdateChecker.ahk
#Include %A_ScriptDir%\Lib\RangerMenu.ahk
#Include %A_ScriptDir%\Lib\Modes\Story.ahk
#Include %A_ScriptDir%\Lib\Modes\RangerStages.ahk
#Include %A_ScriptDir%\Lib\Modes\Raids.ahk
#Include %A_ScriptDir%\Lib\Modes\Portals.ahk
#Include %A_ScriptDir%\Lib\Modes\InfinityCastle.ahk
#Include %A_ScriptDir%\Lib\Modes\BossRush.ahk
#Include %A_ScriptDir%\Lib\Modes\Swarm.ahk
#Include %A_ScriptDir%\Lib\Modes\AdventureMode.ahk

global scriptInitialized := true