#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
#Include Functions.ahk

;Theme colors
global uiTheme := []
uiTheme.Push("0xffffff")  ; Header color
uiTheme.Push("0c000a")    ; Background color
uiTheme.Push("0xffffff")  ; Border color
uiTheme.Push("0c000a")    ; Accent color
uiTheme.Push("0x3d3c36")  ; Trans color
uiTheme.Push("000000")    ; Textbox color
uiTheme.Push("00ffb3")    ; HighLight

;Update Checker
global repoOwner := "itsRynsRoblox"
global repoName := "anime-rangers-x"
global currentVersion := "1.5.8"

; Basic Application Info
global GameTitle := "Ryn's Anime Rangers X "
global rblxID := "ahk_exe RobloxPlayerBeta.exe"
global version := "v" . currentVersion
;Coordinate and Positioning Variables
global targetWidth := 816
global targetHeight := 638
global offsetX := -5
global offsetY := 1
global WM_SIZING := 0x0214
global WM_SIZE := 0x0005
global centerX := 408
global centerY := 320
global successfulCoordinates := []
global maxedCoordinates := []
;Hotkeys
global F1Key := "F1"
global F2Key := "F2"
global F3Key := "F3"
global F4Key := "F4"
;Statistics Tracking
global Wins := 0
global loss := 0
global mode := ""
global StartTime := A_TickCount
global currentTime := GetCurrentTime()

global unitCardsVisible := true
global inStage := false
;Auto Challenge
global challengeStartTime := A_TickCount
global inChallengeMode := false
global challengeStageCount := 0
global challengeMapIndex := 1
global firstStartup := true
global challengeMapList := ["Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City", "Ghoul City", "Night Colosseum"]
global challengeMapActCount := [3, 3, 3, 3, 3, 5, 3]
;Boss Attack
global BossAttackStartTime := A_TickCount
global inBossAttackMode := false
global BossAttackMapStegeCount := 0
global BossAttackMapIndex := 1
global StartupBossAttack := true
global justHitBossAttackCooldown := false
global BossAttackMapList := ["Boss Attack"]
global BossAttackMapActCount := [3] ; Only 3 act for Boss Attack
;Webhook
global firstWebhook := true
;Gui creation
global currentTheme := "Red"
global uiBorders := []
global uiBackgrounds := []
global UnitData := []
global MainUI := Gui("+AlwaysOnTop -Caption")
global lastlog := ""
global MainUIHwnd := MainUI.Hwnd
global ActiveControlGroup := ""
;Logs/Save settings
global settingsGuiOpen := false
global SettingsGUI := ""
global currentOutputFile := A_ScriptDir "\Logs\LogFile.txt"

;Custom Pictures
GithubImage := "Images\github-logo.png"
DiscordImage := "Images\discord_logo.png"

if !DirExist(A_ScriptDir "\Logs") {
    DirCreate(A_ScriptDir "\Logs")
}
if !DirExist(A_ScriptDir "\Settings") {
    DirCreate(A_ScriptDir "\Settings")
}

setupOutputFile()

;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
MainUI.BackColor := uiTheme[2]
global Webhookdiverter := MainUI.Add("Edit", "x0 y0 w1 h1 +Hidden", "") ; diversion
uiBorders.Push(MainUI.Add("Text", "x0 y0 w1364 h1 +Background" uiTheme[3]))  ;Top line
uiBorders.Push(MainUI.Add("Text", "x0 y0 w1 h697 +Background" uiTheme[3]))   ;Left line
uiBorders.Push(MainUI.Add("Text", "x1363 y0 w1 h630 +Background" uiTheme[3])) ;Right line
uiBorders.Push(MainUI.Add("Text", "x1363 y0 w1 h697 +Background" uiTheme[3])) ;Second Right line
uiBackgrounds.Push(MainUI.Add("Text", "x3 y3 w1360 h27 +Background" uiTheme[2])) ;Title Top
uiBorders.Push(MainUI.Add("Text", "x0 y30 w1363 h1 +Background" uiTheme[3])) ;Title bottom

uiBorders.Push(MainUI.Add("Text", "x803 y550 w560 h1 +Background" uiTheme[3])) ;Placement bottom
uiBorders.Push(MainUI.Add("Text", "x803 y385 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(MainUI.Add("Text", "x803 y420 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(MainUI.Add("Text", "x803 y610 w560 h1 +Background" uiTheme[3])) ;Toggles top
uiBorders.Push(MainUI.Add("Text", "x802 y30 w1 h667 +Background" uiTheme[3])) ;Roblox Right
uiBorders.Push(MainUI.Add("Text", "x0 y632 w1364 h1 +Background" uiTheme[3], "")) ;Roblox second bottom

global robloxHolder := MainUI.Add("Text", "x3 y33 w797 h597 +Background" uiTheme[5], "") ;Roblox window box
global exitButton := MainUI.Add("Picture", "x1330 y1 w32 h32 +BackgroundTrans", Exitbutton) ;Exit image
exitButton.OnEvent("Click", (*) => Destroy()) ;Exit button
global minimizeButton := MainUI.Add("Picture", "x1300 y3 w27 h27 +Background" uiTheme[2], Minimize) ;Minimize gui
minimizeButton.OnEvent("Click", (*) => minimizeUI()) ;Minimize gui
MainUI.SetFont("Bold s16 c" uiTheme[1], "Verdana") ;Font
global windowTitle := MainUI.Add("Text", "x10 y3 w1200 h29 +BackgroundTrans", GameTitle "" . "" version) ;Title

MainUI.Add("Text", "x805 y390 w558 h25 +Center +BackgroundTrans", "Process") ;Process header
MainUI.SetFont("norm s11 c" uiTheme[1]) ;Font
global process1 := MainUI.Add("Text", "x810 y420 w600 h18 +BackgroundTrans c" uiTheme[7], "Original Creator: Ryn (@TheRealTension)") ;Processes
global process2 := MainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "") ;Processes 
global process3 := MainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process4 := MainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process5 := MainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process6 := MainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "") 
WinSetTransColor(uiTheme[5], MainUI) ;Roblox window box

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS

OpenDebug(*) {
    DebugGUI := Gui("+AlwaysOnTop")
    DebugGUI.SetFont("s10 bold", "Segoe UI")
    DebugGUI.Title := "Debug Mode"

    DebugGUI.BackColor := "0c000a"
    DebugGUI.MarginX := 20
    DebugGUI.MarginY := 20

    ; Add Guide content
    DebugGUI.SetFont("s16 bold", "Segoe UI")
    DebugGUI.Add("GroupBox","h400 w240 cwhite +Center", "Welcome to Debug")
    DebugGUI.SetFont("s10 bold", "Segoe UI")
    ScreenResChecker := DebugGUI.Add("Button", "x40 y60 w200 cWhite +Center", "Screen Resolution")
    ScreenResChecker.OnEvent("Click", (*) => GetScreenInfo())

    MouseMovementChecker := DebugGUI.Add("Button", "x40 y140 w200 cWhite +Center", "Mouse")
    MouseMovementChecker.OnEvent("Click", (*) => MouseMovementDebug())

    FindTextWorkingChecker := DebugGUI.Add("Button", "x40 y220 w200 cWhite +Center", "Find Text")
    FindTextWorkingChecker.OnEvent("Click", (*) => OpenFindTextDebug())

    ImageSearchDebugChecker := DebugGUI.Add("Button", "x40 y300 w200 cWhite +Center", "Image Search")
    ImageSearchDebugChecker.OnEvent("Click", (*) => ImageSearchDebug())

    ReconnectChecker := DebugGUI.Add("Button", "x40 y380 w200 cWhite +Center", "Rejoin Game/Private Server")
    ReconnectChecker.OnEvent("Click", (*) => RejoinPrivateServer(true))

    DebugGUI.SetFont("s8 bold", "Segoe UI")
    DebugGUI.Add("Text"," x25 y100 cwhite +Center", "Check If Your Computer Settings Are Correct")
    DebugGUI.Add("Text"," x25 y180 cwhite +Center", "Check If The Macro Can Move Your Mouse")
    DebugGUI.Add("Text"," x50 y260 cwhite +Center", "Check If FindText() function work")
    DebugGUI.Add("Text"," x42.5 y340 cwhite +Center", "Check If ImageSearch() function work")
    DebugGUI.Show("w290")
}

ImageSearchDebug(){
    ImageSearchThing := Gui("+AlwaysOnTop")
    ImageSearchThing.BackColor := "0c000a"
    Sleep (1000)
    ImageSearchThing.Add("Picture", "", FindTextDebugImage)
    ImageSearchThing.Show("w300")
    Sleep (1000)
    if (ok := ImageSearch(&X, &Y, 0, 0, 1000, 1000, FindTextDebugImage)){
        ImageSearchThing.Add("Text","cWhite +Center","Image Found This Is A Good Step To Debugging")
    } else{
       ImageSearchThing.Add("Text","cWhite +Center","Image Not Found Please Contact Support Or Check Resolution Debug")
    }
    ImageSearchThing.Show("w300 h100")

}

MouseMovementDebug(){
    MouseMove(0,0)
    MouseDebug := Gui("+AlwaysOnTop")
    MouseDebug.BackColor := "0c000a"
    sleep 1000
    MouseDebug.Add("Text", "w300 cWhite +Center","If your mouse didnt move its likely due to Riot/Vanguard Anticheat Pleas turn it off")
    MouseDebug.Show("w300")
    
}

GetScreenInfo() {
    ScreenInfoGUI := Gui("+AlwaysOnTop")
    ScreenInfoGUI.BackColor := "0c000a"
    screenWidth := SysGet(78)  ; Get screen width
    screenHeight := SysGet(79) ; Get screen height
    dpi := DllCall("user32\GetDpiForSystem", "UInt")  ; Get system DPI
    zoom := Round(dpi / 96 * 100)  ; Calculate Zoom %
     if (screenWidth = 1920 && screenHeight = 1080 && zoom = 100) {
        ScreenInfoGUI.Add("Text", "w300 cWhite +Center","Your resolution settings are correct! The script should work. Screen Resolution: `n" screenWidth "x" screenHeight "`nZoom Level: " zoom "%`n-----------------`nIf you have vanguard/riot anti-cheat, please turn it off")

    } else {
        ScreenInfoGUI.Add("Text","w300 cWhite +Center","Your resolution or zoom is different from what the script needs!`n YOUR SETTING:`nScreen Resolution:`n" screenWidth "x" screenHeight "`nZoom: " zoom "%`n-----------------`nHAS TO BE`n1920x1080`nZoom Level 100%`nFOR MORE HELP CLICK ON THIS TEXT<=`n-----------------`nIf you have vanguard/riot cheat turn it off").OnEvent("Click", (*) => OpenDiscord())
    }
    ScreenInfoGUI.Show("w300")
}

OpenGuide(*) {
    NewGuideGUI := Gui("+AlwaysOnTop")
    NewGuideGUI.SetFont("s10 bold", "Segoe UI")
    NewGuideGUI.Title := "Anime Ranger Guides"

    NewGuideGUI.BackColor := "0c000a"
    NewGuideGUI.MarginX := 20
    NewGuideGUI.MarginY := 20

    ; Add Guide content
    NewGuideGUI.SetFont("s16 bold", "Segoe UI")
    NewGuideGUI.Add("GroupBox","h280 w240 cwhite +Center", "Anime Ranger Guides")
    NewGuideGUI.SetFont("s10 bold", "Segoe UI")

    RobloxSettings := NewGuideGUI.Add("Button", "x40 y60 w200 cWhite +Center", "Roblox Settings")
    RobloxSettings.OnEvent("Click", (*) => OpenRobloxSettings())

    RangerSettings := NewGuideGUI.Add("Button", "x40 y140 w200 cWhite +Center", "Anime Ranger Settings")
    RangerSettings.OnEvent("Click", (*) => OpenRangerSettings())

    NewGuideGUI.SetFont("s8 bold", "Segoe UI")
    NewGuideGUI.Add("Text"," x50 y100 cwhite +Center", "View Recommended Roblox Settings")
    NewGuideGUI.Add("Text"," x40 y180 cwhite +Center", "View Recommended Ranger Settings")

    NewGuideGUI.Show("w290")
}

MainUI.SetFont("s9 Bold c" uiTheme[1])

;DEBUG
DebugButton := MainUI.Add("Button", "x600 y5 w90 h20 +Center", "Debug")
DebugButton.OnEvent("Click", (*) => OpenDebug())

global guideBtn := MainUI.Add("Button", "x700 y5 w90 h20", "Guides")
guideBtn.OnEvent("Click", OpenGuide)

global mapButton := MainUI.Add("Button", "x800 y5 w90 h20", "Map Skips")
mapButton.OnEvent("Click", (*) => OpenMapSkipPriorityPicker())

global modesButton := MainUI.Add("Button", "x900 y5 w90 h20", "Mode Config")
modesButton.OnEvent("Click", (*) => ToggleControlGroup("Mode"))

global timersButton := MainUI.Add("Button", "x1100 y5 w90 h20", "Timers")
timersButton.OnEvent("Click", (*) => ToggleControlGroup("Timers"))

global upgradesButton := MainUI.Add("Button", "x1000 y5 w90 h20", "Upgrades")
upgradesButton.OnEvent("Click", (*) => ToggleControlGroup("Upgrade"))

global settingsBtn := MainUI.Add("Button", "x1200 y5 w90 h20", "Settings")
settingsBtn.OnEvent("Click", (*) => ToggleControlGroup("Settings"))
;settingsBtn.OnEvent("Click", ShowSettingsGUI)

placementSaveBtn := MainUI.Add("Button", "x807 y580 w80 h20", "Save")
placementSaveBtn.OnEvent("Click", SaveSettings)

MainUI.SetFont("s9")

;Normal Options
global NextLevelBox := MainUI.Add("Checkbox", "x900 y560 cffffff Checked", "Next Level")
global PortalFarm := MainUI.Add("Checkbox", "x1000 y560 cffffff Checked Hidden", "Auto Farm Portals")
global ReturnLobbyBox := MainUI.Add("Checkbox", "x900 y560 cffffff Checked", "Return To Lobby")
global ReplayBox := MainUI.Add("Checkbox", "x900 y560 cffffff Checked", "Replay")
global MatchMaking := MainUI.Add("Checkbox", "x900 y580 cffffff Hidden Checked", "Matchmaking") 
;Auto Settings
global AutoPlay := MainUI.Add("CheckBox", "x808 y615 cffffff", "Summon Units")

global ShouldUpgradeUnits := MainUI.Add("CheckBox", "x940 y615 cffffff", "Upgrade Units")
;global ChallengeBox := MainUI.Add("CheckBox", "x1048 y615 cffffff", "Farm Ranger Stages")
global AutoAbility := MainUI.Add("CheckBox", "x1075 y615 cffffff", "Auto Ultimate")
global BossAttackBox := MainUI.Add("CheckBox", "x1075 y595 cffffff", "Auto Boss Attack")
global UpdateMessages := MainUI.Add("CheckBox", "x1200 y615 cffffff", "Update Messages")

global GameSpeedText := MainUI.Add("Text", "x1245 y565 w100 h20 +Center ", "Game Speed")
global GameSpeed := MainUI.Add("DropDownList", "x1250 y585 w100 h180 Choose1", ["2x", "3x"])

; Mode Settings
global AutoStart := MainUI.Add("Checkbox", "x818 y123.5 +Center Hidden", " Using Auto Start (Anime Ranger's Auto Start)")
global AutoRetry := MainUI.Add("Checkbox", "x818 y163.5 +Center Hidden", " Using Auto Replay (Anime Ranger's Auto Replay)")
global AutoGameSpeed := MainUI.Add("Checkbox", "x818 y203.5 +Center Hidden", " Using Auto Game Speed (Anime Ranger's Auto Game Speed)")
; Timer Settings
LobbySleepText := MainUI.Add("Text", "x818 y123.5 w130 h20 +Center Hidden", "Lobby Sleep Timer")
global LobbySleepTimer := MainUI.Add("DropDownList", "x950 y120 w100 h180 Hidden Choose1", ["No Delay", "5 Seconds", "10 Seconds", "15 Seconds", "20 Seconds", "25 Seconds", "30 Seconds", "35 Seconds", "40 Seconds", "45 Seconds", "50 Seconds", "55 Seconds", "60 Seconds"])

WebhookSleepText := MainUI.Add("Text", "x818 y163.5 w130 h20 +Center Hidden", "Webhook Timer")
global WebhookSleepTimer := MainUI.Add("DropDownList", "x950 y160 w100 h180 Hidden Choose1", ["No Delay", "1 minute", "3 minutes", "5 minutes", "10 minutes"])

LoadingScreenWaitTimeText := MainUI.Add("Text", "x818 y203.5 w160 h20 +Center Hidden", "Loading Screen Timer")
global LoadingScreenWaitTime := MainUI.Add("DropDownList", "x980 y200 w100 h180 Hidden Choose1", ["15 Seconds", "20 Seconds", "25 Seconds", "30 Seconds", "35 Seconds", "40 Seconds", "45 Seconds", "50 Seconds", "55 Seconds", "60 Seconds"])

InfinityCastleTimeText := MainUI.Add("Text", "x1085 y203.5 w160 h20 +Center Hidden", "Inf Castle Path Timer")
global InfinityCastleTime := MainUI.Add("Edit", "x1244 y200 w40 h20 Hidden cBlack Number", "10")

BossRushTimerText := MainUI.Add("Text", "x1085 y243.5 w160 h20 +Center Hidden", "Boss Rush Path Timer")
global BossRushTime := MainUI.Add("Edit", "x1244 y240 w40 h20 Hidden cBlack Number", "10")

VoteTimeoutTimerText := MainUI.Add("Text", "x818 y243.5 w160 h20 +Center Hidden", "Vote Timeout Timer")
global VoteTimeoutTimer := MainUI.Add("DropDownList", "x980 y240 w100 h180 Hidden Choose1", ["2 Seconds", "3 seconds", "4 Seconds", "6 Seconds", "7 Seconds", "8 Seconds", "9 Seconds", "10 Seconds"])

ReturnToLobbyTimerText := MainUI.Add("Text", "x818 y283.5 w160 h20 +Center Hidden", "Return To Lobby Timer")
global ReturnToLobbyTimer := MainUI.Add("DropDownList", "x980 y280 w100 h180 Hidden Choose1", ["Never", "5 minutes", "10 minutes", "15 minutes", "20 minutes", "25 minutes", "30 minutes", "60 minutes"])

BossAttackCDTimerText := MainUI.Add("Text", "x818 y325 w160 h20 +Center Hidden", "Redo Boss Attack to") ; Will be hidden by default now
global BossAttackCDTimer := MainUI.Add("DropDownList", "x1000  y325 w100 h180 Hidden Choose5", ["10 minutes", "15 minutes", "20 minutes", "25 minutes", "30 minutes", "20s Test"]) ; Will be hidden

; New fields for Timers GUI only
UltimateCheckText := MainUI.Add("Text", "x1058 y123.5 w200 h20 +Center Hidden", "Ultimate Check (seconds)")
global UltimateCheckEdit := MainUI.Add("Edit", "x1244 y120 w100 h20 Hidden cBlack Number", "60")

; Add Upgrade (seconds) before Ultimate Check
UpgradeBeforeUltimateText := MainUI.Add("Text", "x1058 y163.5 w160 h20 +Center Hidden", "Upgrade (seconds)")
global UpgradeBeforeUltimateEdit := MainUI.Add("Edit", "x1244 y163.5 w100 h20 Hidden cBlack Number", "0")

; Unit Settings
UpgradeClicksText := MainUI.Add("Text", "x818 y123.5 w130 h20 +Center Hidden", "Upgrade Clicks")
global UpgradeClicks := MainUI.Add("Edit", "x950 y120 w100 Hidden cBlack Number", "1")
global UpgradeUntilMaxed := MainUI.Add("CheckBox", "x830 y163.5 Hidden cffffff", "Upgrade units to max before upgrading next unit")

global WebhookBorder := MainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Webhook Settings")
global WebhookEnabled := MainUI.Add("CheckBox", "x825 y110 Hidden cffffff", "Webhook Enabled")
WebhookEnabled.OnEvent("Click", (*) => ValidateWebhook())
global WebhookLogsEnabled := MainUI.Add("CheckBox", "x825 y130 Hidden cffffff", "Send Console Logs")
global WebhookURLBox := MainUI.Add("Edit", "x1000 y108 w260 h20 Hidden c" uiTheme[6], "")

global PrivateSettingsBorder := MainUI.Add("GroupBox", "x808 y145 w550 h236 +Center Hidden c" uiTheme[1], "Reconnection Settings")
global PrivateServerEnabled := MainUI.Add("CheckBox", "x825 y175 Hidden cffffff", "Reconnect to Private Server")
global PrivateServerURLBox := MainUI.Add("Edit", "x1050 y173 w160 h20 Hidden c" uiTheme[6], "")
PrivateServerTestButton := MainUI.Add("Button", "x1225 y173 w80 h20 Hidden", "Test Link")

; HotKeys
global KeybindBorder := MainUI.Add("GroupBox", "x808 y205 w195 h176 +Center Hidden c" uiTheme[1], "Keybind Settings")
global F1Text := MainUI.Add("Text", "x825 y230 Hidden c" uiTheme[1], "Position Roblox:")
global F1Box := MainUI.Add("Edit", "x950 y228 w30 h20 Hidden c" uiTheme[6], F1Key)
global F2Text := MainUI.Add("Text", "x825 y260 Hidden c" uiTheme[1], "Start Macro:")
global F2Box := MainUI.Add("Edit", "x950 y258 w30 h20 Hidden c" uiTheme[6], F2Key)
global F3Text := MainUI.Add("Text", "x825 y290 Hidden c" uiTheme[1], "Stop Macro:")
global F3Box := MainUI.Add("Edit", "x950 y288 w30 h20 Hidden c" uiTheme[6], F3Key)
global F4Text := MainUI.Add("Text", "x825 y320 Hidden c" uiTheme[1], "Pause Macro:")
global F4Box := MainUI.Add("Edit", "x950 y318 w30 h20 Hidden c" uiTheme[6], F4Key)

keybindSaveBtn := MainUI.Add("Button", "x880 y350 w50 h20 Hidden", "Save")
keybindSaveBtn.OnEvent("Click", SaveKeybindSettings)

StoryDifficultyText := MainUI.Add("Text", "x890 y585 w80 h20 +Center", "Difficulty")
global StoryDifficulty := MainUI.Add("DropDownList", "x970 y580 w100 h180 Choose1", ["Normal", "Hard", "Nightmare"])

placementSaveText := MainUI.Add("Text", "x807 y560 w80 h20", "Save Config")
Hotkeytext := MainUI.Add("Text", "x807 y35 w500 h30", "Below are the default hotkey settings ")
Hotkeytext2 := MainUI.Add("Text", "x807 y50 w500 h30", "F1:Fix Roblox Window|F2:Start Macro|F3:Stop Macro|F4:Pause Macro")

DiscordButton := MainUI.Add("Picture", "x30 y645 w60 h34 +BackgroundTrans cffffff", DiscordImage)
DiscordButton.OnEvent("Click", (*) => OpenDiscord())

global TimerSettings := MainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Timer Settings")
global UnitSettings := MainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Upgrade Settings")
global ModeSettings := MainUI.Add("GroupBox", "x808 y85 w550 h296 +Center Hidden c" uiTheme[1], "Mode Config")

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT
global modeSelectionGroup := MainUI.Add("GroupBox", "x808 y38 w500 h45 Background" uiTheme[2], "Mode Select")
MainUI.SetFont("s10 c" uiTheme[6])
global ModeDropdown := MainUI.Add("DropDownList", "x818 y53 w140 h180 Choose0 +Center", ["Story", "Boss Rush", "Ranger Stages", "Raid", "Challenge", "Infinity Castle", "Portal", "Co-op"])
global StoryDropdown := MainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City", "Ghoul City", "Night Colosseum", "Bizzare Race"])
global StoryActDropdown := MainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Act 7", "Act 8", "Act 9", "Act 10"])
global RangerDropdown := MainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center Hidden", ["Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City", "Ghoul City", "Night Colosseum"])
global RangerActDropdown := MainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center Hidden", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5"])
global LegendDropDown := MainUI.Add("DropDownlist", "x968 y53 w150 h180 Choose0 +Center", [""] )
global LegendActDropdown := MainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Random"])
global RaidDropdown := MainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Steel Blitz Rush"])
global RaidActDropdown := MainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4"])
global InfinityCastleDropdown := MainUI.Add("DropDownList", "x968 y53 w80 h180 Choose0 +Center", ["Normal", "Hard"])
global ConfirmButton := MainUI.Add("Button", "x1218 y53 w80 h25", "Confirm")
global PortalDropdown := MainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Ghoul City Portal", "Night Colosseum Portal"])

StoryDropdown.Visible := false
StoryActDropdown.Visible := false
LegendDropDown.Visible := false
LegendActDropdown.Visible := false
RaidDropdown.Visible := false
RaidActDropdown.Visible := false
InfinityCastleDropdown.Visible := false
MatchMaking.Visible := false
ReturnLobbyBox.Visible := false
ReplayBox.Visible := false
NextLevelBox.Visible := false
StoryDifficulty.Visible := false
StoryDifficultyText.Visible := false
PortalDropdown.Visible := false
Hotkeytext.Visible := false
Hotkeytext2.Visible := false

ModeDropdown.OnEvent("Change", OnModeChange)
StoryDropdown.OnEvent("Change", OnStoryChange)
StoryActDropdown.OnEvent("Change", OnStoryActChange)
LegendDropDown.OnEvent("Change", OnLegendChange)
RaidDropdown.OnEvent("Change", OnRaidChange)
ConfirmButton.OnEvent("Click", OnConfirmClick)

RangerDropdown.OnEvent("Change", (*) => OnRangerMapChange())

OnRangerMapChange() {
    map := RangerDropdown.Text
    if (map = "Z City" || map = "Ghoul City") {
        RangerActDropdown.Delete()
        RangerActDropdown.Add(["Act 1", "Act 2", "Act 3", "Act 4", "Act 5"])
        RangerActDropdown.Value := 1
    } else {
        RangerActDropdown.Delete()
        RangerActDropdown.Add(["Act 1", "Act 2", "Act 3"])
        RangerActDropdown.Value := 1
    }
}
;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION
AddUnitCard(MainUI, index, x, y) {
    unit := {}
 
    unit.Background := MainUI.Add("Text", Format("x{} y{} w550 h45 +Background{}", x, y, uiTheme[4]))
    unit.BorderTop := MainUI.Add("Text", Format("x{} y{} w550 h2 +Background{}", x, y, uiTheme[3]))
    unit.BorderBottom := MainUI.Add("Text", Format("x{} y{} w552 h2 +Background{}", x, y+45, uiTheme[3]))
    unit.BorderLeft := MainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x, y, uiTheme[3]))
    unit.BorderRight := MainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+85, y, uiTheme[3]))
    unit.BorderRight2 := MainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+300, y, uiTheme[3]))
    unit.BorderRight3 := MainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+550, y, uiTheme[3]))

    MainUI.SetFont("s11 Bold c" uiTheme[1])
    unit.Title := MainUI.Add("Text", Format("x{} y{} w60 h25 +BackgroundTrans", x+30, y+15), "Slot " index)

    MainUI.SetFont("s9 c" uiTheme[1])
    unit.PlacementText := MainUI.Add("Text", Format("x{} y{} w200 h20 +BackgroundTrans", x+100, y+2), "Summon && Upgrade Priority")

    unit.UpgradeText := MainUI.Add("Text", Format("x{} y{} w140 h20 +BackgroundTrans", x+330, y+5), "Upgrade Enabled")

    unit.UpgradeBeforeSummonText := MainUI.Add("Text", Format("x{} y{} w200 h20 +BackgroundTrans", x+330, y+25), "Max upgrade before summon")
    
    UnitData.Push(unit)
    return unit
}

;Create Unit slot
y_start := 85
y_spacing := 50
Loop 6 {
    AddUnitCard(MainUI, A_Index, 808, y_start + ((A_Index-1)*y_spacing))
}

enabled1 := MainUI.Add("CheckBox", "x818 y102 w15 h15", "")
enabled2 := MainUI.Add("CheckBox", "x818 y152 w15 h15", "")
enabled3 := MainUI.Add("CheckBox", "x818 y202 w15 h15", "")
enabled4 := MainUI.Add("CheckBox", "x818 y252 w15 h15", "")
enabled5 := MainUI.Add("CheckBox", "x818 y302 w15 h15", "")
enabled6 := MainUI.Add("CheckBox", "x818 y352 w15 h15", "")

upgradeEnabled1 := MainUI.Add("CheckBox", "x1120 y90 w15 h15", "")
upgradeEnabled2 := MainUI.Add("CheckBox", "x1120 y140 w15 h15", "")
upgradeEnabled3 := MainUI.Add("CheckBox", "x1120 y190 w15 h15", "")
upgradeEnabled4 := MainUI.Add("CheckBox", "x1120 y240 w15 h15", "")
upgradeEnabled5 := MainUI.Add("CheckBox", "x1120 y290 w15 h15", "")
upgradeEnabled6 := MainUI.Add("CheckBox", "x1120 y340 w15 h15", "")

upgradeBeforeSummon1 := MainUI.Add("CheckBox", "x1120 y110 w15 h15", "")
upgradeBeforeSummon2 := MainUI.Add("CheckBox", "x1120 y160 w15 h15", "")
upgradeBeforeSummon3 := MainUI.Add("CheckBox", "x1120 y210 w15 h15", "")
upgradeBeforeSummon4 := MainUI.Add("CheckBox", "x1120 y260 w15 h15", "")
upgradeBeforeSummon5 := MainUI.Add("CheckBox", "x1120 y310 w15 h15", "")
upgradeBeforeSummon6 := MainUI.Add("CheckBox", "x1120 y360 w15 h15", "")


MainUI.SetFont("s8 c" uiTheme[6])

; Placement dropdowns
Placement1 := MainUI.Add("DropDownList", "x970 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement2 := MainUI.Add("DropDownList", "x970 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement3 := MainUI.Add("DropDownList", "x970 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement4 := MainUI.Add("DropDownList", "x970 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement5 := MainUI.Add("DropDownList", "x970 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement6 := MainUI.Add("DropDownList", "x970 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

readInSettings()
MainUI.Show("w1366 h633")
WinMove(0, 0,,, "ahk_id " MainUIHwnd)
forceRobloxSize()  ; Initial force size and position
;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS

;Process text
AddToLog(current) { 
    global process1, process2, process3, process4, process5, process6, currentOutputFile, lastlog

    ; Remove arrow from all lines first
    process6.Value := StrReplace(process5.Value, "➤ ", "")
    process5.Value := StrReplace(process4.Value, "➤ ", "")
    process4.Value := StrReplace(process3.Value, "➤ ", "")
    process3.Value := StrReplace(process2.Value, "➤ ", "")
    process2.Value := StrReplace(process1.Value, "➤ ", "")
    
    ; Add arrow only to newest process
    process1.Value := "➤ " . current
    
    elapsedTime := getElapsedTime()
    Sleep(50)
    FileAppend(current . " " . "[" getCurrentTime() "]" . "`n", currentOutputFile)

    ; Add webhook logging
    lastlog := current
    if FileExist("Settings\SendActivityLogs.txt") {
        SendActivityLogsStatus := FileRead("Settings\SendActivityLogs.txt", "UTF-8")
        if (SendActivityLogsStatus = "1") {
            WebhookLog()
        }
    }
}

;Timer
getElapsedTime() {
    global StartTime
    ElapsedTime := A_TickCount - StartTime
    Minutes := Mod(ElapsedTime // 60000, 60)  
    Seconds := Mod(ElapsedTime // 1000, 60)
    return Format("{:02}:{:02}", Minutes, Seconds)
}

;Basically the code to move roblox, below

sizeDown() {
    global rblxID

    if !WinExist(rblxID)
        return

    try {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
    } catch {
        AddToLog("Failed to get window position.")
        return ; Safely exit if the window doesn't exist or can't get position
    }

    ; Exit fullscreen if needed
    if (OutWidth >= A_ScreenWidth && OutHeight >= A_ScreenHeight) {
        Send "{F11}"
        Sleep(100)
    }

    ; Force the window size and retry if needed
    Loop 3 {
        try {
            WinMove(X, Y, targetWidth, targetHeight, rblxID)
            Sleep(100)
            WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
            if (OutWidth == targetWidth && OutHeight == targetHeight)
                break
        } catch {
            AddToLog("Failed to get window position.")
            break ; Stop trying if something goes wrong
        }
    }
}
moveRobloxWindow() {
    global MainUIHwnd, offsetX, offsetY, rblxID
    
    if !WinExist(rblxID) {
        AddToLog("Waiting for Roblox window...")
        return
    }

    ; First ensure correct size
    sizeDown()
    
    ; Then move relative to main UI
    WinGetPos(&x, &y, &w, &h, MainUIHwnd)
    WinMove(x + offsetX, y + offsetY,,, rblxID)
    WinActivate(rblxID)
}

forceRobloxSize() {
    global rblxID
    
    if !WinExist(rblxID) {
        checkCount := 0
        While !WinExist(rblxID) {
            Sleep(5000)
            if(checkCount >= 5) {
                AddToLog("Attempting to locate the Roblox window")
            } 
            checkCount += 1
            if (checkCount > 12) { ; Give up after 1 minute
                AddToLog("Could not find Roblox window")
                return
            }
        }
        AddToLog("Found Roblox window")
    }

    WinActivate(rblxID)
    sizeDown()
    moveRobloxWindow()
}

; Function to periodically check window size
checkRobloxSize() {
    global rblxID
    if WinExist(rblxID) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth != targetWidth || OutHeight != targetHeight) {
            sizeDown()
            moveRobloxWindow()
        }
    }
}
;Basically the code to move roblox, Above

OnSettingsGuiClose(*) {
    global settingsGuiOpen, SettingsGUI
    settingsGuiOpen := false
    if SettingsGUI {
        SettingsGUI.Destroy()
        SettingsGUI := ""  ; Clear the GUI reference
    }
}

checkSizeTimer() {
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, "ahk_exe RobloxPlayerBeta.exe")
        if (OutWidth != 816 || OutHeight != 638) {
            AddToLog("Fixing Roblox window size")
            moveRobloxWindow()
        }
    }
}

OpenFindTextDebug(*) {
    GuideGUI := Gui("+AlwaysOnTop")
    GuideGUI.SetFont("s10 bold", "Segoe UI")
    GuideGUI.Title := "Find Text Debug"

    FindTextOrder := GuideGUI.Add("GroupBox", "x20 y25 w180 h100 +Center cWhite", "FindText Debug")
    FindTextDebugButton := GuideGUI.Add("Button", "x65 y80 h20 w90 cWhite +Center", "Debug")

    GuideGUI.BackColor := "0c000a"
    GuideGUI.MarginX := 20
    GuideGUI.MarginY := 20

    FindTextDropdown := GuideGUI.Add("DropDownList", "x50 y50 w120 h180", ["Create Room", "Unit Manager", "Vote Screen"])
    FindTextDebugButton.OnEvent("Click", (*) => TestFindText(FindTextDropdown.Text))

    GuideGUI.Show()
}

TestFindText(text := "") {
    if (WinExist(rblxID)) {
        WinActivate(rblxID)
    }
    if (text = "Create Room") {
        if (GetFindText().FindText(&X, &Y, 12, 241, 148, 275, 0.05, 0.20, CreateRoom)) {
            AddToLog("Found the FindText() for " text)
            FixClick(X, Y - 35, "Right")
            return true
        }
    }
    else if (text = "Unit Manager") {
        if (GetFindText().FindText(&X, &Y, 609, 463, 723, 495, 0.05, 0.20, UnitManagerBack)) {
            AddToLog("Found the FindText() for " text)
            FixClick(X, Y - 35, "Right")
            return true
        }
    }
    else if (text = "Vote Screen") {
        if (GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
            AddToLog("Found the FindText() for " text)
            FixClick(X, Y - 35, "Right")
            return true
        }
    }
    AddToLog("Didn't find the FindText() for " text)
    return false
}

OpenRobloxSettings(*) {
    GuideGUI := Gui("+AlwaysOnTop")
    GuideGUI.SetFont("s10 bold", "Segoe UI")
    GuideGUI.Title := "Roblox Settings"

    GuideGUI.BackColor := "0c000a"
    GuideGUI.MarginX := 20
    GuideGUI.MarginY := 20

    ; Add Guide content
    GuideGUI.SetFont("s16 bold", "Segoe UI")

    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\Clicktomove.png")
    GuideGUI.Add("Picture", "x50 w700   cWhite +Center", "Images\graphics1.png")
    GuideGUI.Show("w800")
}

OpenRangerSettings(*) {
    GuideGUI := Gui("+AlwaysOnTop")
    GuideGUI.SetFont("s10 bold", "Segoe UI")
    GuideGUI.Title := "Anime Rangers Settings"

    GuideGUI.BackColor := "0c000a"
    GuideGUI.MarginX := 20
    GuideGUI.MarginY := 20

    ; Add Guide content
    GuideGUI.SetFont("s16 bold", "Segoe UI")

    GuideGUI.Add("Text", "x0 w800 cWhite +Center", "Currently there is no recommended settings for Anime Rangers")
    GuideGUI.Show("w800")
}

ToggleControlGroup(groupName) {
    global ActiveControlGroup
    if (ActiveControlGroup = groupName) {
        ShowOnlyControlGroup("Default") ; hide all
        ActiveControlGroup := ""
        AddToLog("Displaying: Default UI")
        ShowUnitCards()
    } else {
        ShowOnlyControlGroup(groupName)
        ActiveControlGroup := groupName
        AddToLog("Displaying: " groupName " Settings UI")
        HideUnitCards()
    }
}

SetUnitCardVisibility(visible) {
    for _, unit in UnitData {
        for _, control in unit.OwnProps() {
            if IsObject(control)
                control.Visible := visible
        }
    }

    controlNames := [
        "Placement", "enabled", "upgradeEnabled", "upgradeBeforeSummon"
    ]

    for name in controlNames {
        loop 6 {
            control := %name%%A_Index%
            if IsObject(control)
                control.Visible := visible
        }
    }
}

HideUnitCards() {
    SetUnitCardVisibility(false)
}

ShowUnitCards() {
    SetUnitCardVisibility(true)
}

ShowOnlyControlGroup(groupToShow) {
    global ControlGroups := Map()

    ControlGroups["Default"] := [
        Placement1, Placement2, Placement3, Placement4, Placement5, Placement6,
        enabled1, enabled2, enabled3, enabled4, enabled5, enabled6,
        upgradeEnabled1, upgradeEnabled2, upgradeEnabled3, upgradeEnabled4, upgradeEnabled5, upgradeEnabled6,
    ]
    
    ControlGroups["Upgrade"] := [
        UnitSettings, UpgradeClicks, UpgradeClicksText, UpgradeUntilMaxed
    ]
    
    ControlGroups["Timers"] := [
        TimerSettings, LobbySleepText, LobbySleepTimer, WebhookSleepText, WebhookSleepTimer, LoadingScreenWaitTime, LoadingScreenWaitTimeText, VoteTimeoutTimerText, VoteTimeoutTimer, ReturnToLobbyTimerText, ReturnToLobbyTimer, BossAttackCDTimerText, BossAttackCDTimer, 
        UltimateCheckText, UltimateCheckEdit, 
        UpgradeBeforeUltimateText, UpgradeBeforeUltimateEdit,
        InfinityCastleTimeText, InfinityCastleTime,
        BossRushTimerText, BossRushTime ; , RangerCDTimerText, RangerCDTimer,
    ]

    ControlGroups["Mode"] := [
        ModeSettings, AutoStart, AutoRetry, AutoGameSpeed
    ]

    ControlGroups["Settings"] := [
        WebhookBorder, WebhookEnabled, WebhookLogsEnabled, WebhookURLBox,
        PrivateSettingsBorder, PrivateServerEnabled, PrivateServerURLBox, PrivateServerTestButton,
        KeybindBorder, F1Text, F1Box, F2Text, F2Box, F3Text, F3Box, F4Text, F4Box, keybindSaveBtn 
    ]

    for name, controls in ControlGroups {
        isVisible := (name = groupToShow)
        for control in controls {
            if IsObject(control)
                control.Visible := isVisible
        }
    }
    ; Ensure BossAttackCDTimer controls are visible if Timers group is shown
    BossAttackCDTimerText.Visible := (groupToShow = "Timers")
    BossAttackCDTimer.Visible := (groupToShow = "Timers")
}

ValidateWebhook() {
    url := WebhookURLBox.Value
    
    if (url == "") {
        WebhookEnabled.Value := false
        WebhookURLBox.Value := ""
        MsgBox("Webhook URL cannot be blank. Please enter a valid Webhook URL.", "Missing URL", "+0x1000")
        return
    }
    
    if (!RegExMatch(url, "^https://discord\.com/api/webhooks/.*")) {
        WebhookEnabled.Value := false
        WebhookURLBox.Value := ""
        MsgBox("Invalid Webhook URL! Please ensure it follows the correct format.", "Invalid URL", "+0x1000")
        return
    }
}