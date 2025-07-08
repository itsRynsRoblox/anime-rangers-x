#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

global autoAbilityClicking := false

global autoAbilityTimerId := 0

global autoAbilityStopTimerId := 0

global autoAbilityCoords := [
    [588, 208],
    [659, 196],
    [735, 205],
    [576, 253],
    [665, 257],
    [754, 265],
    [629, 197],
    [703, 196]
]

global isUpgrading := true

global upgradeBeforeUltimateUsed := false

; FindText patterns for abilities
global ability1Text := "|<>**50$113.0000000000Dk000000000000zk000Nbs00000000007Vs000VQk0000000000Q0s0012kU0000000001U0s0025V0000000000600s004/6T000000000A7UzjrsHDzk00000000EzVltwkaS1U00000001VVVXVkVNs100000000363333X2rU6000000006A266265x7w00000000AM4C84A823s00000000MMMQ00sE60s00000000Etlg01kUC0k00000000kz3M46VkTVU00000001U0CkMB1UrX000000001U0Mkkm1306000000003U1VXla260A000000003kC1brC471k000000001zs3twDs7z0000000000S000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007s0000000000003s000Dk0000000001k0Cs000FU000000000Ds0Mk000V0000000000Mk0lU00120000000000lU1X00024000001y001X037yTXw9zzzzwDzTzj7k6DAnS8L6CMwQs7n7s1UAQ92k0w0M0kPU703k10MsG701k0k00S0603U20lkYA0301U00sAA070A1XV8MQ6733VlkwMS7Xtn72EkwAP673XU0kw/67yC7VVsMyAC7701V8KAMsQD33UksMQCC7z2EgSk0w0701k0ksQQ7i4VMDU3s0C03U1Vksw0A92kDUCM0K05U33Vlw0MG5kPUswtjCNz7BbXQ1taNsnzUTz7zryDvxyTzzDlz0s00000MsM0007k00000000000k1U0000000000000001U700000000000000001kQ00000000000000001zk0000000008"

global ability2Text := "|<>**50$113.0000000000003w0000000000zw000006A0000000003Uw000008M000000000A0Q00000EE000000000k0M00000UU000000001U0E00001100000000023VUTU002200000000047z3zlz7w40000000008DwC1n6MM8000000000MDkk0o4kkE000000000k3v00s9VUU000000001k0q01kH310000000001k0sD1Ua620000000001w1kT31AA40000000007z1Va62MM8000000000Ty33AA6kkE000000001lw63kQD1Us0000000031sA30s031s00000000600w03k070k00000000601w06k0C1U00000000C06Q0tk8Q3000000000D0sS3Vtti600000000007zUDy0zzDs0000000001k000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001y00TU000007zw000003C00nU00000C1y000004A013000000E0C0000088022000000U0C00000Ek04400000100A00000nU08800000200Nk0001y3wEE03w1bY7kTszzzXyzyUzUTyTzs9ksn3X3aBUD13Vk7lVkFVUa601cS0601a0701Uz31AA01kQ0Q01s06031w62MM03Ukws03k8A0C00Q4kkA31UzEA31sMDw00s9VUw63UDUw63kkTc03EH31gA7071gA01UUE0SUy62MM/062MM0310UzlVsA4kkLUA4kkTy211y300M9VUvsM9VUzw4220600kH31VkkH3U0s8440601Ua6301Ua700kE880C133AAC073AD01VUMk0DDD6QwT0z6MnU7X0zU0DzzsTzrzrwTXzzy0000000000000000z002"

global ability3Text := "|<>**50$51.00703U00007y0zU0000kk6rU000Anzqz0001jOKwM000BvGrj0001jM6wM000AXhrv0000lxiQM0007wzzz00000000000Q0w000007U7U0007UoPhzySza6zxzzzzwspgAAHVV3KhhddBhgzphhhhVhaoVVVhhxgqCiihhlhmzzzxzzzzk004Q0000000z00000003U0000U"

global ability4Text := "|<>**50$44.00y0zU000TkBs000A7zHs003Rzrq000rOZvU00Bq3SM0039Yru000sxRtU007zzzs000000001s7U001kS1c000S5zvzzzxlTyzzzzAKo8EB8HxhOZPGpxOIdKrhDDKgJiPPzzzbzzzk00X000000Dk000U"

global ability5Text := "|<>**50$44.00y0zU000TkBs000A7zHs003Rzrq000rOZvU00Bq3SM0039Yru000sxRtU007zzzs000000001s7U001kS1c000S5zvzzzxlTyzzzzAKo8EB8HxhOZPGpxOIdKrhDDKgJiPPzzzbzzzk00X000000Dk000U"

global ability6Text := "|<>**50$47.00000s0007w03s000QM06k000mzzxU001jvzv000371iq0007WnRg000DZqnM000N8A6E000sswgk000zzTz0000000000000C3U01y00wD000C01cO000DzzzrbzrTzztjxxirMRf3UX1iqPCnNSTNir5qSly3Rh/gxXCKvMrQPCDzzzzzyE"

global ability7Text := "|<>**50$34.000801y0007jzU00OkrzzzfTCSzygQoW4+rrGvKjTBvhGwCtiqfzzzzzw000000DVs001z6U006Dvzs0PvjyU1X2kW07ZfOs0OIh+01Xauc03zzzU8"

global ability9Text := "|<>*149$29.rzzzz0zzzy0zzzwlQksNWNUUEAnDAUNaQ1DnAwyTUNs4zUnsTzzzzzzzzzzzzzzzzzzzzzzzzzzzznzzzzbzzzzDsPn2TU340zAaNVwN0U3sn37UM7700sST3"

global ultGuiText := "|<>**50$42.07zs0000DzM0000A1M0000Azzzs00AzPSQ00A78MA00A79tY00Az9s4U0Az9Nw00AX9MA00BXPAAE0DXzDwE000000E000000E00000003k000007s000006M00000CPzzzzzADPPnrvQD331qNNbDDAm/M7DDQk3k3//AsWnn//0taqPPNXhqyTvtzDwU"

global newFindText := "|<>**50$46.03kS00000T3s00001YAk00006FnDzU00N67hz001YsS0A006HAt4k00NQ3av001ZU6Pg006KSNik00PPBiv001xwzzw0000000000000000000000003k0003s0TjU00BU1aq000q06TTzzzzsksSSrxtn31Us0m3NbCNYH9xURvaPgjg0raNimTnn61av8DNiSSvhtzbzTzzzyU"

SavePsSettings(*) {
    AddToLog("Saving Private Server")

    if FileExist("Settings\PrivateServer.txt")
        FileDelete("Settings\PrivateServer.txt")

    FileAppend(PsLinkBox.Value, "Settings\PrivateServer.txt", "UTF-8")
}

SaveUINavSettings(*) {
    AddToLog("Saving UI Navigation Key")

    if FileExist("Settings\UINavigation.txt")
        FileDelete("Settings\UINavigation.txt")

    FileAppend(UINavBox.Value, "Settings\UINavigation.txt", "UTF-8")
}

;Opens discord Link
OpenDiscordLink() {
    Run("https://discord.gg/mistdomain")
 }

 ;Minimizes the UI
 minimizeUI(*){
    arMainUI.Minimize()
 }

 Destroy(*){
    arMainUI.Destroy()
    ExitApp
 }
 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }

 getCurrentTime() {
    currentHour := A_Hour
    currentMinute := A_Min
    currentSecond := A_Sec
    amPm := (currentHour >= 12) ? "PM" : "AM"

    ; Convert to 12-hour format
    currentHour := Mod(currentHour - 1, 12) + 1

    return Format("{:d}:{:02}:{:02} {}", currentHour, currentMinute, currentSecond, amPm)
}



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text

    ; Hide all dropdowns first
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    RangerDropdown.Visible := false
    RangerActDropdown.Visible := false
    MatchMaking.Visible := false
    ReturnLobbyBox.Visible := false
    ReplayBox.Visible := false
    PortalDropdown.Visible := false


    if (selected = "Story") {
        StoryDropdown.Visible := true
        StoryActDropdown.Visible := true
        mode := "Story"
    } else if (selected = "Ranger") {
        RangerDropdown.Visible := false
        RangerActDropdown.Visible := false
        mode := "Ranger"
    } else if (selected = "Legend") {
        LegendDropDown.Visible := true
        LegendActDropdown.Visible := true
        mode := "Legend"
    } else if (selected = "Raid") {
        RaidDropdown.Visible := true
        RaidActDropdown.Visible := true
        mode := "Raid"
    } else if (selected = "Infinity Castle") {
        InfinityCastleDropdown.Visible := true
        mode := "Infinity Castle"
    } else if (selected = "Coop") {
        mode := "Coop"
    } else if (selected = "Boss Attack") {
        mode := "Boss Attack"
    } else if (selected = "Portal") {
        PortalDropdown.Visible := true
        mode := "Portal"
    } 

}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnStoryActChange(*) {

}

OnLegendChange(*) {
    if (LegendDropDown.Text != "") {
        LegendActDropdown.Visible := true
    } else {
        LegendActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text " - " StoryActDropdown.Text)
        mode := "Story"
        MatchMaking.Visible := false
        NextLevelBox.Visible := (StoryActDropdown.Text != "Infinity")
        StoryDifficulty.Visible := (StoryActDropdown.Text != "Infinity")
        StoryDifficultyText.Visible := (StoryActDropdown.Text != "Infinity")
    } else if (ModeDropdown.Text = "Ranger") {
        mode := "Ranger"
        AddToLog("Selected Range Mode")
        MatchMaking.Visible := false
        ReplayBox.Visible := true
    } else if (ModeDropdown.Text = "Boss Event") {
        mode := "Boss Event"
        AddToLog("Selected Boss Event")
    } else if (ModeDropdown.Text = "Challenge") {
        mode := "Challenge"
        AddToLog("Selected Challenge Mode")
        ReturnLobbyBox.Visible := true
    } else if (ModeDropdown.Text = "Coop") {
        mode := "Coop"
        AddToLog("Selected Coop Mode")
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    } else if (ModeDropdown.Text = "Portal") {
        mode := "Portal"
        PortalDropdown.Visible := false
        AddToLog("Selected Portal Mode with name: " PortalDropdown.Text)
    } else if (ModeDropdown.Text = "Boss Attack") {
        mode := "Boss Attack"
        AddToLog("Selected Boss Attack Mode")
        MatchMaking.Visible := false
        ReturnLobbyBox.Visible := true
    } else if (ModeDropdown.Text = "Legend") {
        if (LegendDropDown.Text = "" || LegendActDropdown.Text = "") {
            AddToLog("Please select both Legend Stage and Act before confirming")
            return
        }
        mode := "Legend"
        AddToLog("Selected " LegendDropDown.Text " - " LegendActDropdown.Text)
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    } else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "" || RaidActDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        mode := "Raid"
        AddToLog("Selected " RaidDropdown.Text " - " RaidActDropdown.Text)
        MatchMaking.Visible := false
        NextLevelBox.Visible := true
    } else if (ModeDropdown.Text = "Infinity Castle") {
        if (InfinityCastleDropdown.Text = "") {
            AddToLog("Please select an Infinity Castle difficulty before confirming")
            return
        }
        mode := "Infinity Castle"
        AddToLog("Selected Infinity Castle - " InfinityCastleDropdown.Text)
        MatchMaking.Visible := false
    } else {
        mode := ModeDropdown.Text
        AddToLog("Selected " ModeDropdown.Text " mode")
        MatchMaking.Visible := false
    }

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    RangerDropdown.Visible := false
    RangerActDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

OpenDiscord() {
    Run("https://discord.gg/mistdomain")
}

SearchFor(Name) {
    FindTexts := Map()

    ; Check if the FindText exists in the map
    if !FindTexts.Has(Name) {
        AddToLog("Error: Couldn't find " Name "...")
        return false  ; Invalid name
    }

    coords := FindTexts[Name].coords
    searchTexts := FindTexts[Name].searchTexts
    x1 := coords[1], y1 := coords[2], x2 := coords[3], y2 := coords[4]

    ; Loop through all search texts to perform the Find Text search
    for searchText in searchTexts {
        if (GetFindText().FindText(&X, &Y, x1, y1, x2, y2, 0.20, 0.20, searchText)) {
            return true  ; FindText found
        }
    }

    return false  ; FindText not found
}

WaitFor(Name, timeout := 5000) {
    startTime := A_TickCount  ; Get current time

    ; **Wait for the FindText to appear**
    Loop {
        if (SearchFor(Name)) {
            if (debugMessages) {
                AddToLog("✅ " Name " detected, proceeding...")
            }
            return true  ; Interface found, exit loop
        }
        if ((A_TickCount - startTime) > timeout) {
            if (debugMessages) {
                AddToLog("⚠ " Name " was not found in time.")
            }
            return false  ; Exit if timeout reached
        }
        Sleep 100  ; Fast checks for better responsiveness
    }
}

HasValue(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}

AttachDropDownEvent(dropDown, index, callback) {
    dropDown.OnEvent("Change", (*) => callback(dropDown, index))
}

RemoveEmptyStrings(array) {
    loop array.Length {
        i := array.Length - A_Index + 1
        if (array[i] = "") {
            array.RemoveAt(i)
        }
    }
}

StringJoin(array, delimiter := ", ") {
    result := ""
    ; Convert the array to an Object to make it enumerable
    for index, value in array {
        if (index > 1)
            result .= delimiter
        result .= value
    }
    return result
}

GetMousePos() {
    MouseGetPos(&x, &y)
    A_Clipboard := ""  ; Clear the clipboard first
    ClipWait(0.5)  ; Optional: wait for it to clear

    A_Clipboard := x ", " y
    ClipWait(0.5)  ; Wait for the clipboard to be ready

    if (A_Clipboard = x ", " y) {
        AddToLog("Copied: " x ", " y)
    } else {
        AddToLog("Failed to copy coordinates.")
    }
}

ScrollToBottom() {
    loop 3 {
        SendInput("{WheelDown}")
        Sleep(250)
    }
}

ScrollToTop() {
    loop 3 {
        SendInput("{WheelUp}")
        Sleep(50)
    }
}

TeleportToSpawn() {
    FixClick(18, 574) ; Click Settings
    Sleep(1000)
    FixClick(539, 290)
    Sleep(1000)
    FixClick(180, 574) ; Click Settings to close
    Sleep(1000)
}

ClickReplay() {
    xCoord := (ModeDropdown.Text != "Story" || StoryDropdown.Text = "Z City") ? -120 : -250
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, xCoord, -35)
    ; Resume AutoAbility if enabled
    if (IsSet(AutoAbility) && AutoAbility.Value) {
        AddToLog("[AutoAbility] Resuming after Replay.")
        AutoAbilityRoutine()
        Sleep(50)
        SendInput("{T}")
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickReplayRanger() {
    AddToLog("Clicking Replay...")
    FixClick(213, 394)
    Sleep (500)
    ; Resume AutoAbility if enabled
    if (IsSet(AutoAbility) && AutoAbility.Value) {
        AddToLog("[AutoAbility] Resuming after Replay.")
        AutoAbilityRoutine()
        Sleep(50)
        SendInput("{T}")
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickNextLevel() {
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, -120, -35)
    ; Resume AutoAbility if enabled
    if (IsSet(AutoAbility) && AutoAbility.Value) {
        AddToLog("[AutoAbility] Resuming after Next Level.")
        AutoAbilityRoutine()
        Sleep(50)
        SendInput("{T}")
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickReplayBossAttack() {
    AddToLog("[Boss Attack] Clicking Replay Boss Attack...")
    FixClick(250, 397)
    Sleep (500)
    ; Resume AutoAbility if enabled
    if (IsSet(AutoAbility) && AutoAbility.Value) {
        AddToLog("[AutoAbility] Resuming after Replay Boss Attack.")
        AutoAbilityRoutine()
        Sleep(50)
        SendInput("{T}")
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickReplay2() {
    AddToLog("Clicking Replay...")
    FixClick(211, 390)
    Sleep (500)
    ; Resume AutoAbility if enabled
    if (IsSet(AutoAbility) && AutoAbility.Value) {
        AddToLog("[AutoAbility] Resuming after Replay Boss Attack.")
        AutoAbilityRoutine()
        Sleep(50)
        SendInput("{T}")
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickReturnToLobby() {
    inStage := false
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, 0, -35)
    ; Stop Auto Ability if running
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        AddToLog("[AutoAbility] Stopped after returning to lobby.")
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        Sleep(200)
    }
    global upgradeBeforeUltimateUsed
    upgradeBeforeUltimateUsed := false
}

ClickStartStory() {
    ClickUntilGone(0, 0, 320, 468, 486, 521, StartStoryButton, 0, -35)
}

ClickThroughDrops() {
    if (debugMessages) {
        AddToLog("Clicking through item drops...")
    }
    VoteCheck()
    Loop 5 {
        FixClick(400, 495)
        Sleep(500)
    }
}

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    waitTime := A_TickCount ; Start timer
    while (ok := GetFindText().FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || textToFind2 && GetFindText().FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
        if ((A_TickCount - waitTime) > 300000) { ; 5-minute limit
            AddToLog("5 minute failsafe triggered, trying to open roblox...")
            return RejoinPrivateServer()
        }
        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY)
        } else {
            FixClick(x, y)
        }
        Sleep(1000)
    }
}

RightClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    while (ok := GetFindText().FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) ||
           textToFind2 && GetFindText().FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {

        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY, "Right")
        } else {
            FixClick(x, y, "Right")
        }
        Sleep(1000)
    }
}

GetDuration(index, durations) {
    if index is number
        return durations[index]
}

SleepTime() {
    return GetDuration(LobbySleepTimer.Value, [0, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000])
}

GetLoadingScreenWaitTime() {
    return GetDuration(LoadingScreenWaitTime.Value, [15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000])
}

GetVoteTimeoutTime() {
    return GetDuration(VoteTimeoutTimer.Value, [2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000])
}

GetReturnToLobbyTimer() {
    return GetDuration(ReturnToLobbyTimer.Value, [0, 300000, 600000, 900000, 1200000, 1500000, 1800000, 3600000])
}

GetBossAttackCDTime() {
    return GetDuration(BossAttackCDTimer.Value, [600000, 900000, 1200000, 1500000, 1800000, 20000])
}

GetLoadingWaitInSeconds() {
    ms := GetLoadingScreenWaitTime()
    return Round(ms / 1000, 1)  ; Return with 1 decimal place for precision
}

GetWebhookDelay() {
    return GetDuration(WebhookSleepTimer.Value, [10, 60000, 180000, 300000, 600000])
}

CheckForVoteScreen() {
    inStage := false
    if (ok := GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
        FixClick(400, 150)
        return true
    }
}

CheckForCooldownMessage() {
    if (ok := GetFindText().FindText(&X, &Y, 365, 205, 402, 231, 0, 0, RangerCooldownMessage)) {
        return true
    }
}

; Safe accessor for the FindText class
GetFindText() {
    static obj := FindTextClass()
    return obj
}

AutoAbilityRoutine() {
    global autoAbilityClicking, autoAbilityTimerId, UltimateCheckEdit, UpgradeBeforeUltimateEdit, upgradeBeforeUltimateUsed
    
    ; เช็คว่ากลับ lobby แล้วหรือยัง
    if (IsInLobby()) {
        AddToLog("[AutoAbility] Detected lobby. Stopping Auto Ability.")
        autoAbilityClicking := false
        if (autoAbilityTimerId) {
            SetTimer(autoAbilityTimerId, 0)
            autoAbilityTimerId := 0
        }
        SetTimer(AutoAbility_ClickLoop, 0)
        return
    }

    AddToLog("[AutoAbility] Cycle started. Checking if Upgrade (seconds) pause is needed...")
    autoAbilityClicking := false
    if (autoAbilityTimerId) {
        SetTimer(autoAbilityTimerId, 0)
        autoAbilityTimerId := 0
    }
    ; Only run Upgrade (seconds) timer once per game, and only as a pause before Ultimate Check
    if (!upgradeBeforeUltimateUsed && (UpgradeBeforeUltimateEdit && UpgradeBeforeUltimateEdit.Value != "" && UpgradeBeforeUltimateEdit.Value > 0)) {
        upgradeBeforeUltimateUsed := true
        AddToLog("[AutoAbility] Pausing for Upgrade (seconds): " UpgradeBeforeUltimateEdit.Value " seconds before starting Ultimate Check.")
        isUpgrading := true
        SetTimer(AutoAbilityRoutine, -UpgradeBeforeUltimateEdit.Value * 1000)
        return
    }
    ; Now start the Ultimate Check timer
    ultimateDelay := (UltimateCheckEdit && UltimateCheckEdit.Value != "") ? UltimateCheckEdit.Value * 1000 : 60000
    AddToLog("[AutoAbility] Starting Ultimate Check timer for " (ultimateDelay/1000) " seconds.")
    SetTimer(AutoAbility_UltimateCheckEnd, -ultimateDelay)
}

AutoAbility_UltimateCheckEnd() {
    global autoAbilityClicking, isUpgrading
    AddToLog("[AutoAbility] Ultimate Check timer ended. Stopping upgrades and sending X.")
    ; Stop upgrading
    isUpgrading := false
    Sleep(200)
    ; Send X key (simulate close)
    AddToLog("[AutoAbility] Sending X key.")
    SendInput("{X}")
    AddToLog("[AutoAbility] X key sent.")
    Sleep(200)
    ; Start ability detection loop
    autoAbilityClicking := true
    SetTimer(AutoAbility_ClickLoop, 100)
}

AutoAbility_ClickLoop() {
    global autoAbilityClicking, ability1Text, ability2Text, ability3Text, ability4Text, ability5Text, ability6Text, ability7Text, ultGuiText, isUpgrading
    if (!autoAbilityClicking) {
        SetTimer(AutoAbility_ClickLoop, 0)
        return
    }

    ; Function to click all instances of an ability
    ClickAllInstances(x1, y1, x2, y2, text) {
        local foundAny := false
        while (ok := FindText(&X, &Y, x1, y1, x2, y2, 0, 0, text)) {
            foundAny := true
            ; Click at (158, 535) first to ensure clicks work
            FindText().Click(158, 535, "L")
            Sleep(1)
            ; Click all found instances
            for i, v in ok {
                FindText().Click(v.x, v.y, "L")
                Sleep(1)
            }
            Sleep(500)  ; 1 second sleep between different abilities
        }
        return foundAny
    }

    ; List abilities to check
    abilities := [
        [1240-150000, 408-150000, 1240+150000, 408+150000, ability1Text],
        [1237-150000, 405-150000, 1237+150000, 405+150000, ability2Text],
        [666-150000, 229-150000, 666+150000, 229+150000, ability3Text],
        [666-150000, 227-150000, 666+150000, 227+150000, ability4Text],
        [666-150000, 227-150000, 666+150000, 227+150000, ability5Text],
        [667-150000, 225-150000, 667+150000, 225+150000, ability6Text],
        [666-150000, 298-150000, 666+150000, 298+150000, ability7Text],
        [528, 151, 797, 457, ability9Text],
        [666-150000, 226-150000, 666+150000, 226+150000, ultGuiText],
        [666-150000, 226-150000, 666+150000, 226+150000, newFindText]
    ]

    foundAnyAbility := false
    for _, ab in abilities {
        if (ok := FindText(&X, &Y, ab[1], ab[2], ab[3], ab[4], 0, 0, ab[5])) {
            ; เจอสกิล กดใช้
            FindText().Click(158, 535, "L")
            Sleep(1)
            for i, v in ok {
                FindText().Click(v.x, v.y, "L")
                Sleep(1)
            }
            Sleep(500) ; กันกดรัว
            foundAnyAbility := true
            break ; ออกจากลูปทันทีหลังเจอสกิล
        }
    }

    if (foundAnyAbility) {
        ; รีเซ็ต timer ใหม่ (วนกลับมาเช็คอีกครั้งหลัง delay)
        SetTimer(AutoAbility_ClickLoop, -1000) ; 1 วินาที (ปรับได้)
    } else {
        ; ไม่เจอสกิล หยุด AutoAbility
        AddToLog("[AutoAbility] No abilities detected, stopping and resuming upgrades.")
        isUpgrading := true
        SendInput("{T}")
        SetTimer(AutoAbility_ClickLoop, 0)
        AddToLog("[AutoAbility] Auto Ability stopped and upgrading resumed.")
        ; Auto-resume after Ultimate Check if enabled
    }
}