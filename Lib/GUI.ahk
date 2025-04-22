#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Image.ahk
#Include Functions.ahk

;Update Checker
global repoOwner := "itsRynsRoblox"
global repoName := "anime-rangers-x "
global currentVersion := "1.1.2"

; Basic Application Info
global aaTitle := "Ryn's Anime Rangers X "
global version := "v" . currentVersion
global rblxID := "ahk_exe RobloxPlayerBeta.exe"
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
;Auto Challenge
global challengeStartTime := A_TickCount
global inChallengeMode := false
global challengeStageCount := 0
global challengeMapIndex := 1
global firstStartup := true
global challengeMapList := ["Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"]
;Gui creation
global uiBorders := []
global uiBackgrounds := []
global uiTheme := []
global UnitData := []
global arMainUI := Gui("+AlwaysOnTop -Caption")
global lastlog := ""
global arMainUIHwnd := arMainUI.Hwnd
;Theme colors
uiTheme.Push("0xffffff")  ; Header color
uiTheme.Push("0c000a")  ; Background color
uiTheme.Push("0xffffff")    ; Border color
uiTheme.Push("0c000a")  ; Accent color
uiTheme.Push("0x3d3c36")   ; Trans color
uiTheme.Push("000000")    ; Textbox color
uiTheme.Push("00ffb3") ; HighLight
;Logs/Save settings
global settingsGuiOpen := false
global SettingsGUI := ""
global currentOutputFile := A_ScriptDir "\Logs\LogFile.txt"
global WebhookURLFile := "Settings\WebhookURL.txt"
global DiscordUserIDFile := "Settings\DiscordUSERID.txt"
global SendActivityLogsFile := "Settings\SendActivityLogs.txt"

;Custom Pictures
GithubImage := "Images\github-logo.png"
DiscordImage := "Images\another_discord.png"

if !DirExist(A_ScriptDir "\Logs") {
    DirCreate(A_ScriptDir "\Logs")
}
if !DirExist(A_ScriptDir "\Settings") {
    DirCreate(A_ScriptDir "\Settings")
}

setupOutputFile()

;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------
arMainUI.BackColor := uiTheme[2]
global Webhookdiverter := arMainUI.Add("Edit", "x0 y0 w1 h1 +Hidden", "") ; diversion
uiBorders.Push(arMainUI.Add("Text", "x0 y0 w1364 h1 +Background" uiTheme[3]))  ;Top line
uiBorders.Push(arMainUI.Add("Text", "x0 y0 w1 h697 +Background" uiTheme[3]))   ;Left line
uiBorders.Push(arMainUI.Add("Text", "x1363 y0 w1 h630 +Background" uiTheme[3])) ;Right line
uiBorders.Push(arMainUI.Add("Text", "x1363 y0 w1 h697 +Background" uiTheme[3])) ;Second Right line
uiBackgrounds.Push(arMainUI.Add("Text", "x3 y3 w1360 h27 +Background" uiTheme[2])) ;Title Top
uiBorders.Push(arMainUI.Add("Text", "x0 y30 w1363 h1 +Background" uiTheme[3])) ;Title bottom

uiBorders.Push(arMainUI.Add("Text", "x803 y550 w560 h1 +Background" uiTheme[3])) ;Placement bottom
uiBorders.Push(arMainUI.Add("Text", "x803 y385 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(arMainUI.Add("Text", "x803 y420 w560 h1 +Background" uiTheme[3])) ;Process bottom
uiBorders.Push(arMainUI.Add("Text", "x802 y30 w1 h667 +Background" uiTheme[3])) ;Roblox Right
uiBorders.Push(arMainUI.Add("Text", "x0 y632 w1364 h1 +Background" uiTheme[3], "")) ;Roblox second bottom

global robloxHolder := arMainUI.Add("Text", "x3 y33 w797 h597 +Background" uiTheme[5], "") ;Roblox window box
global exitButton := arMainUI.Add("Picture", "x1330 y1 w32 h32 +BackgroundTrans", Exitbutton) ;Exit image
exitButton.OnEvent("Click", (*) => Destroy()) ;Exit button
global minimizeButton := arMainUI.Add("Picture", "x1300 y3 w27 h27 +Background" uiTheme[2], Minimize) ;Minimize gui
minimizeButton.OnEvent("Click", (*) => minimizeUI()) ;Minimize gui
arMainUI.SetFont("Bold s16 c" uiTheme[1], "Verdana") ;Font
global windowTitle := arMainUI.Add("Text", "x10 y3 w1200 h29 +BackgroundTrans", aaTitle "" . "" version) ;Title

arMainUI.Add("Text", "x805 y390 w558 h25 +Center +BackgroundTrans", "Activity Log") ;Process header
arMainUI.SetFont("norm s11 c" uiTheme[1]) ;Font
global process1 := arMainUI.Add("Text", "x810 y420 w600 h18 +BackgroundTrans c" uiTheme[7], "➤ Original Creator: Ryn (@TheRealTension)") ;Processes
global process2 := arMainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "") ;Processes 
global process3 := arMainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process4 := arMainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process5 := arMainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "")
global process6 := arMainUI.Add("Text", "xp yp+22 w600 h18 +BackgroundTrans", "") 
WinSetTransColor(uiTheme[5], arMainUI) ;Roblox window box

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
ShowSettingsGUI(*) {
    global settingsGuiOpen, SettingsGUI
    
    ; Check if settings window already exists
    if (SettingsGUI && WinExist("ahk_id " . SettingsGUI.Hwnd)) {
        WinActivate("ahk_id " . SettingsGUI.Hwnd)
        return
    }
    
    if (settingsGuiOpen) {
        return
    }
    
    settingsGuiOpen := true
    SettingsGUI := Gui("-MinimizeBox +Owner" arMainUIHwnd)  
    SettingsGui.Title := "Settings"
    SettingsGUI.OnEvent("Close", OnSettingsGuiClose)
    SettingsGUI.BackColor := uiTheme[2]
    
    ; Window border
    SettingsGUI.Add("Text", "x0 y0 w1 h300 +Background" uiTheme[3])     ; Left
    SettingsGUI.Add("Text", "x599 y0 w1 h300 +Background" uiTheme[3])   ; Right
    SettingsGUI.Add("Text", "x0 y281 w600 h1 +Background" uiTheme[3])   ; Bottom
    
    ; Right side sections
    SettingsGUI.SetFont("s10", "Verdana")
    SettingsGUI.Add("GroupBox", "x310 y5 w280 h160 Center c" uiTheme[1], "Discord Webhook")  ; Box
    
    SettingsGUI.SetFont("s9", "Verdana")
    SettingsGUI.Add("Text", "x320 y30 c" uiTheme[1], "Webhook URL")     ; Webhook Text
    global WebhookURLBox := SettingsGUI.Add("Edit", "x320 y50 w260 h20 c" uiTheme[6])  ; Store webhook
    SettingsGUI.Add("Text", "x320 y83 c" uiTheme[1], "Discord ID (optional)")  ; Discord Id Text
    global DiscordUserIDBox := SettingsGUI.Add("Edit", "x320 y103 w260 h20 c" uiTheme[6])  ; Store Discord ID
    global SendActivityLogsBox := SettingsGUI.Add("Checkbox", "x320 y135 c" uiTheme[1], "Send Process")  ; Enable Activity

    ; HotKeys
    SettingsGUI.Add("GroupBox", "x10 y90 w160 h160 c" uiTheme[1], "Keybinds")
    SettingsGUI.Add("Text", "x20 y110 c" uiTheme[1], "Position Roblox:")
    global F1Box := SettingsGUI.Add("Edit", "x125 y110 w30 h20 c" uiTheme[6], F1Key)
    SettingsGUI.Add("Text", "x20 y140 c" uiTheme[1], "Start Macro:")
    global F2Box := SettingsGUI.Add("Edit", "x100 y140 w30 h20 c" uiTheme[6], F2Key)
    SettingsGUI.Add("Text", "x20 y170 c" uiTheme[1], "Stop Macro:")
    global F3Box := SettingsGUI.Add("Edit", "x100 y170 w30 h20 c" uiTheme[6], F3Key)
    SettingsGUI.Add("Text", "x20 y200 c" uiTheme[1], "Pause Macro:")
    global F4Box := SettingsGUI.Add("Edit", "x110 y200 w30 h20 c" uiTheme[6], F4Key)

    ; Private Server section
    SettingsGUI.Add("GroupBox", "x310 y175 w280 h100 Center c" uiTheme[1], "Private Server")  ; Box

    SettingsGUI.Add("Text", "x320 y195 c" uiTheme[1], "Private Server Link (optional)")  ; Ps text
    global PsLinkBox := SettingsGUI.Add("Edit", "x320 y215 w260 h20 c" uiTheme[6])  ;  ecit box

    SettingsGUI.Add("GroupBox", "x10 y10 w115 h70 c" uiTheme[1], "UI Navigation")
    SettingsGUI.Add("Text", "x20 y30 c" uiTheme[1], "Navigation Key")
    global UINavBox := SettingsGUI.Add("Edit", "x20 y50 w20 h20 c" uiTheme[6], "\")

    ; Save buttons
    webhookSaveBtn := SettingsGUI.Add("Button", "x460 y135 w120 h25", "Save Webhook")
    webhookSaveBtn.OnEvent("Click", (*) => SaveWebhookSettings())

    PsSaveBtn := SettingsGUI.Add("Button", "x460 y240 w120 h25", "Save PsLink")
    PsSaveBtn.OnEvent("Click", (*) => SavePsSettings())

    keybindSaveBtn := SettingsGUI.Add("Button", "x20 y220 w50 h20", "Save")
    keybindSaveBtn.OnEvent("Click", SaveKeybindSettings)

    UINavSaveBtn := SettingsGUI.Add("Button", "x50 y50 w60 h20", "Save")
    UINavSaveBtn.OnEvent("Click", (*) => SaveUINavSettings())

    ; Loadsettings
    if FileExist(WebhookURLFile)
        WebhookURLBox.Value := FileRead(WebhookURLFile, "UTF-8")
    if FileExist(DiscordUserIDFile)
        DiscordUserIDBox.Value := FileRead(DiscordUserIDFile, "UTF-8")
    if FileExist(SendActivityLogsFile)
        SendActivityLogsBox.Value := (FileRead(SendActivityLogsFile, "UTF-8") = "1")   
    if FileExist("Settings\PrivateServer.txt")
        PsLinkBox.Value := FileRead("Settings\PrivateServer.txt", "UTF-8")
    if FileExist("Settings\UINavigation.txt")
        UINavBox.Value := FileRead("Settings\UINavigation.txt", "UTF-8")

    ; Show the settings window
    SettingsGUI.Show("w600 h285")
    Webhookdiverter.Focus()
}

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

    FindTextWorkingChecker := DebugGUI.Add("Button", "x40 y220 w200 cWhite +Center", "FindText")
    FindTextWorkingChecker.OnEvent("Click", (*) => OpenFindTextDebug())

    ImageSearchDebugChecker := DebugGUI.Add("Button", "x40 y300 w200 cWhite +Center", "ImageSearch")
    ImageSearchDebugChecker.OnEvent("Click", (*) => ImageSearchDebug())

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

arMainUI.SetFont("s9 Bold c" uiTheme[1])

;DEBUG
DebugButton := arMainUI.Add("Button", "x900 y5 w90 h20 +Center", "Debug")
DebugButton.OnEvent("Click", (*) => OpenDebug())

global guideBtn := arMainUI.Add("Button", "x1000 y5 w90 h20", "Guides")
guideBtn.OnEvent("Click", OpenGuide)

global mapButton := arMainUI.Add("Button", "x1100 y5 w90 h20", "Map Skips")
mapButton.OnEvent("Click", (*) => OpenMapSkipPriorityPicker())

global settingsBtn := arMainUI.Add("Button", "x1200 y5 w90 h20", "Settings")
settingsBtn.OnEvent("Click", ShowSettingsGUI)

placementSaveBtn := arMainUI.Add("Button", "x807 y585 w80 h20", "Save")
placementSaveBtn.OnEvent("Click", SaveSettings)

arMainUI.SetFont("s9")

;Normal Options
global NextLevelBox := arMainUI.Add("Checkbox", "x900 y560 cffffff Checked", "Next Level")
global ReturnLobbyBox := arMainUI.Add("Checkbox", "x900 y560 cffffff Checked", "Return To Lobby")
global MatchMaking := arMainUI.Add("Checkbox", "x900 y580 cffffff Hidden Checked", "Matchmaking") 
;Auto Settings
global ChallengeBox := arMainUI.Add("CheckBox", "x900 y610 cffffff", "Auto Ranger Stage")
global AutoPlay := arMainUI.Add("CheckBox", "x1050 y610 cffffff", "Autoplay")
global ShouldUpgradeUnits := arMainUI.Add("CheckBox", "x1140 y610 cffffff", "Auto Upgrade")
; General Settings
LobbySleepText := arMainUI.Add("Text", "x1220 y565 w130 h20 +Center", "Lobby Sleep Timer")
global LobbySleepTimer := arMainUI.Add("DropDownList", "x1235 y585 w100 h180 Choose1", ["No Delay", "5 Seconds", "10 Seconds", "15 Seconds", "20 Seconds", "25 Seconds", "30 Seconds", "35 Seconds", "40 Seconds", "45 Seconds", "50 Seconds", "55 Seconds", "60 Seconds"])

StoryDifficultyText := arMainUI.Add("Text", "x890 y585 w80 h20 +Center", "Difficulty")
global StoryDifficulty := arMainUI.Add("DropDownList", "x970 y580 w100 h180 Choose1", ["Normal", "Hard", "Nightmare"])


placementSaveText := arMainUI.Add("Text", "x807 y565 w80 h20", "Save Config")

Hotkeytext := arMainUI.Add("Text", "x807 y35 w500 h30", "Below are the default hotkey settings ")
Hotkeytext2 := arMainUI.Add("Text", "x807 y50 w500 h30", "F1:Fix Roblox Window|F2:Start Macro|F3:Stop Macro|F4:Pause Macro")
GithubButton := arMainUI.Add("Picture", "x30 y640 w40 h40 +BackgroundTrans cffffff Hidden", GithubImage)
DiscordButton := arMainUI.Add("Picture", "x30 y645 w60 h34 +BackgroundTrans cffffff", DiscordImage)

GithubButton.OnEvent("Click", (*) => OpenGithub())
DiscordButton.OnEvent("Click", (*) => OpenDiscord())

;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS;--------------SETTINGS
;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT;--------------MODE SELECT
global modeSelectionGroup := arMainUI.Add("GroupBox", "x808 y38 w500 h45 Background" uiTheme[2], "Mode Select")
arMainUI.SetFont("s10 c" uiTheme[6])
global ModeDropdown := arMainUI.Add("DropDownList", "x818 y53 w140 h180 Choose0 +Center", ["Story", "Boss Event", "Challenge", "Easter Event"])
global StoryDropdown := arMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", ["Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"])
global StoryActDropdown := arMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Act 7", "Act 8", "Act 9", "Act 10"])
global LegendDropDown := arMainUI.Add("DropDownlist", "x968 y53 w150 h180 Choose0 +Center", [""] )
global LegendActDropdown := arMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Random"])
global RaidDropdown := arMainUI.Add("DropDownList", "x968 y53 w150 h180 Choose0 +Center", [""])
global RaidActDropdown := arMainUI.Add("DropDownList", "x1128 y53 w80 h180 Choose0 +Center", ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5"])
global InfinityCastleDropdown := arMainUI.Add("DropDownList", "x968 y53 w80 h180 Choose0 +Center", ["Normal", "Hard"])
global ConfirmButton := arMainUI.Add("Button", "x1218 y53 w80 h25", "Confirm")

StoryDropdown.Visible := false
StoryActDropdown.Visible := false
LegendDropDown.Visible := false
LegendActDropdown.Visible := false
RaidDropdown.Visible := false
RaidActDropdown.Visible := false
InfinityCastleDropdown.Visible := false
MatchMaking.Visible := false
ReturnLobbyBox.Visible := false
NextLevelBox.Visible := false
StoryDifficulty.Visible := false
StoryDifficultyText.Visible := false
Hotkeytext.Visible := false
Hotkeytext2.Visible := false

ModeDropdown.OnEvent("Change", OnModeChange)
StoryDropdown.OnEvent("Change", OnStoryChange)
StoryActDropdown.OnEvent("Change", OnStoryActChange)
LegendDropDown.OnEvent("Change", OnLegendChange)
RaidDropdown.OnEvent("Change", OnRaidChange)
ConfirmButton.OnEvent("Click", OnConfirmClick)
;------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI------MAIN UI
;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION ;------UNIT CONFIGURATION
AddUnitCard(arMainUI, index, x, y) {
    unit := {}
 
    unit.Background := arMainUI.Add("Text", Format("x{} y{} w550 h45 +Background{}", x, y, uiTheme[4]))
    unit.BorderTop := arMainUI.Add("Text", Format("x{} y{} w550 h2 +Background{}", x, y, uiTheme[3]))
    unit.BorderBottom := arMainUI.Add("Text", Format("x{} y{} w552 h2 +Background{}", x, y+45, uiTheme[3]))
    unit.BorderLeft := arMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x, y, uiTheme[3]))
    unit.BorderRight := arMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+85, y, uiTheme[3]))
    unit.BorderRight := arMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+300, y, uiTheme[3]))
    unit.BorderRight := arMainUI.Add("Text", Format("x{} y{} w2 h45 +Background{}", x+550, y, uiTheme[3]))
    arMainUI.SetFont("s11 Bold c" uiTheme[1])
    unit.Title := arMainUI.Add("Text", Format("x{} y{} w60 h25 +BackgroundTrans", x+30, y+18), "Slot " index)

    arMainUI.SetFont("s9 c" uiTheme[1])
    unit.PlacementText := arMainUI.Add("Text", Format("x{} y{} w200 h20 +BackgroundTrans", x+100, y+2), "Summon && Upgrade Priority")

    unit.UpgradeText := arMainUI.Add("Text", Format("x{} y{} w140 h20 +BackgroundTrans", x+330, y+20), "Upgrade Enabled")
    
    UnitData.Push(unit)
    return unit
}

;Create Unit slot
y_start := 85
y_spacing := 50
Loop 6 {
    AddUnitCard(arMainUI, A_Index, 808, y_start + ((A_Index-1)*y_spacing))
}

enabled1 := arMainUI.Add("CheckBox", "x818 y105 w15 h15", "")
enabled2 := arMainUI.Add("CheckBox", "x818 y155 w15 h15", "")
enabled3 := arMainUI.Add("CheckBox", "x818 y205 w15 h15", "")
enabled4 := arMainUI.Add("CheckBox", "x818 y255 w15 h15", "")
enabled5 := arMainUI.Add("CheckBox", "x818 y305 w15 h15", "")
enabled6 := arMainUI.Add("CheckBox", "x818 y355 w15 h15", "")

upgradeEnabled1 := arMainUI.Add("CheckBox", "x1120 y105 w15 h15", "")
upgradeEnabled2 := arMainUI.Add("CheckBox", "x1120 y155 w15 h15", "")
upgradeEnabled3 := arMainUI.Add("CheckBox", "x1120 y205 w15 h15", "")
upgradeEnabled4 := arMainUI.Add("CheckBox", "x1120 y255 w15 h15", "")
upgradeEnabled5 := arMainUI.Add("CheckBox", "x1120 y305 w15 h15", "")
upgradeEnabled6 := arMainUI.Add("CheckBox", "x1120 y355 w15 h15", "")

arMainUI.SetFont("s8 c" uiTheme[6])

; Placement dropdowns
Placement1 := arMainUI.Add("DropDownList", "x970 y105 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement2 := arMainUI.Add("DropDownList", "x970 y155 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement3 := arMainUI.Add("DropDownList", "x970 y205 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement4 := arMainUI.Add("DropDownList", "x970 y255 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement5 := arMainUI.Add("DropDownList", "x970 y305 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])
Placement6 := arMainUI.Add("DropDownList", "x970 y355 w60 h180 Choose1 +Center", ["1","2","3","4","5","6"])

readInSettings()
arMainUI.Show("w1366 h633")
WinMove(0, 0,,, "ahk_id " arMainUIHwnd)
forceRobloxSize()  ; Initial force size and position
;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS;------FUNCTIONS

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
    FileAppend(current . " " . elapsedTime . "`n", currentOutputFile)

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
    global arMainUIHwnd, offsetX, offsetY, rblxID
    
    if !WinExist(rblxID) {
        AddToLog("Waiting for Roblox window...")
        return
    }

    ; First ensure correct size
    sizeDown()
    
    ; Then move relative to main UI
    WinGetPos(&x, &y, &w, &h, arMainUIHwnd)
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

    FindTextDropdown := GuideGUI.Add("DropDownList", "x60 y50 w100 h180", ["Create Room", "Boss Event", "Unit Manager"])
    FindTextDebugButton.OnEvent("Click", (*) => TestFindText(FindTextDropdown.Text))

    GuideGUI.Show()
}

TestFindText(text := "") {
    if (WinExist(rblxID)) {
        WinActivate(rblxID)
    }
    if (text = "Create Room") {
        if (FindText(&X, &Y, 12, 241, 148, 275, 0.05, 0.20, CreateRoom)) {
            AddToLog("Found the FindText() for " text)
            FixClick(X, Y - 35, "Right")
            return true
        }
    }
    else if (text = "Boss Event") {
        if (FindText(&X, &Y, 400, 375, 508, 404, 0.05, 0.20, BossPlayText)) {
            AddToLog("Found the FindText() for " text)
            FixClick(X, Y - 35, "Right")
            return true
        }
    }
    else if (text = "Unit Manager") {
        if (FindText(&X, &Y, 609, 463, 723, 495, 0.05, 0.20, UnitManagerBack)) {
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