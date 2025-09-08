#Requires AutoHotkey v2.0
#Include Image.ahk

global macroStartTime := A_TickCount
global stageStartTime := A_TickCount
global ReturnToLobbyStartTime := A_TickCount

global inChallengeMode := false
global checkForUnitManager := true
global lastHourCheck := A_Hour
global startingMode := true
global isUpgrading := true
global lastVoteCheck := 0
global voteCheckCooldown := 1500
global currentRangerSkipIndex := 1

;Added for Adventure Mode
global enduresPerRun := 0

LoadKeybindSettings()  ; Load saved keybinds
CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())    
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {

}

F6:: {

}

F7:: {
    CopyMouseCoords(true)
}

F8:: {
    Run (A_ScriptDir "\Lib\FindText.ahk")
}


StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    if (DoesntStartInLobby(ModeDropdown.Text)) {
        if (!IsInLobby()) {
            RestartStage()
        } else {
            AddToLog("You need to be loaded into the proper stage to start " ModeDropdown.Text)
        }
    } else {
        RestartStage()
    }
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddToLog("Macro Paused")
        Sleep(1000)
    } else {
        AddToLog("Macro Resumed")
        Sleep(1000)
    }
}

BossEvent() {
    global startingMode
    BossEventMovement()

    while !(ok := GetFindText().FindText(&X, &Y, 400, 375, 508, 404, 0.05, 0.20, BossPlayText)) {
        Reconnect() ; Added Disconnect Check
        BossEventMovement()
    }

    StartBossEvent()
    startingMode := false
}

ChallengeMode() {    
    global startingMode
    ChallengeCameraChange()
    ChallengeMovement()

    while !(ok := GetFindText().FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        Reconnect() ; Added Disconnect Check
        FixClick(598, 425) ; Click Back
        ChallengeCameraChange()
        ChallengeMovement()
    }

    CreateChallenge()
}


LegendMode() {
    global challengeMapIndex, challengeMapList, challengeStageCount, inChallengeMode, startingMode

    ; Keep skipping until a valid map is found or end of list
    while (challengeMapIndex <= challengeMapList.Length && ShouldSkipMap(challengeMapList[challengeMapIndex], currentLegendAct)) {
        AddToLog(challengeMapList[challengeMapIndex] " is set to be skipped. Skipping...")
        challengeMapIndex++
        Sleep(250)
    }

    if (challengeMapIndex > challengeMapList.Length) {
        AddToLog("No more valid maps to run.")
        inChallengeMode := false
        challengeMapIndex := 1  ; Reset map index for next session
        challengeStageCount := 0  ; Reset stage count for new ranger stage session
    }

    currentLegendMap := challengeMapList[challengeMapIndex]
    currentLegendAct := "Act 1"

    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    OpenPlayMenu()
    
    ; Start stage
    while !(ok := GetFindText().FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        if (debugMessages) {
            AddToLog("Debug: Looking for create room text...")
        }
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        OpenPlayMenu()
    }

    FixClick(25, 225) ; Create Room
    Sleep(1000)

    while !(ok := GetFindText().FindText(&X, &Y, 325, 163, 409, 193, 0.05, 0.20, StoryChapter)) {
        if (debugMessages) {
            AddToLog("Debug: Looking for story chapters Text...")
        }
        FixClick(615, 155) ; Click X on Join
        Sleep(1000)
        FixClick(25, 225) ; Create Room
        Sleep(1000)
        Reconnect() ; Added Disconnect Check
    }

    AddToLog("Starting " currentLegendMap " - " currentLegendAct)
    StartLegend(currentLegendMap, currentLegendAct)

    ; Handle play mode selection
    PlayHere()
}

MonitorEndScreen() {
    global Wins, loss, stageStartTime, lastResult, webhookSendTime, firstWebhook

    isWin := false

    lastClickTime := A_TickCount

    ; Wait for XP to appear or reconnect if necessary
    while !CheckForXp() {
        if ((A_TickCount - lastClickTime) >= 2000) {
            if (CheckForContinue()) {
                HandleEndureOrEvade()
            } else {
                FixClick(400, 495)
            }
            lastClickTime := A_TickCount
        }
        Sleep (150)
    }

    ; --- Handle Auto Ability ---
    if (AutoAbility.Value) {
        SetTimer(CheckAutoAbility, 0)
    }

    if (ModeDropdown.Text = "Infinity Castle" || ModeDropdown.Text = "Boss Rush" ) {
        SetTimer(ChangePath, 0)
    }

    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    CloseChat()

    ; Detect win or loss
    if (GetFindText().FindText(&X, &Y, 377, 228, 536, 276, 0.05, 0.80, DefeatText)) {
        isWin := false
    } else if (GetFindText().FindText(&X, &Y, 397, 222, 538, 273, 0.05, 0.80, VictoryText)) {
        isWin := true
    } else if (GetFindText().FindText(&X, &Y, 380, 186, 584, 300, 0, 0, VictoryText2)) {
        isWin := true
    }

    lastResult := isWin ? "win" : "lose"
    AddToLog((isWin ? "Victory" : "Defeat") " detected - Stage Length: " stageLength)
    (isWin ? Wins += 1 : loss += 1)
    Sleep(200)

    if (WebhookEnabled.Value && (firstWebhook || (A_TickCount - webhookSendTime) >= GetWebhookDelay())) {
        try {
            SendWebhookWithTime(isWin, stageLength)
            webhookSendTime := A_TickCount
            firstWebhook := false
        } catch {
            AddToLog("Error: Unable to send webhook.")
        }
    } else {
        UpdateStreak(isWin)
    }

    ; --- Mode Handling ---
    if (ModeDropdown.Text = "Adventure Mode") {
        enduresPerRun := 0
    }

    if (ModeDropdown.Text = "Story") {
        HandleStoryMode()
    } else if (ModeDropdown.Text = "Ranger Stages") {
        HandleRangerMode()
    } else if (ModeDropdown.Text = "Raid") {
        HandleStoryMode()
    } else if (ModeDropdown.Text = "Portal") {
        HandlePortalMode()
    } else if (ModeDropdown.Text = "Infinity Castle") {
        HandleInfinityCastle()
    } else {
        HandleDefaultMode()
    }
}

HandleStoryMode() {
    global lastResult

    if (lastResult = "win" && NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else if (GetMapForFarming(StoryDropdown.Text) != "no map found" && PortalFarm.Value) {
        SwitchActiveFarm()
        Sleep(1500)
        ClickReturnToLobby()
        CheckLobby()
    } else if (ShouldReturnToLobby()) {
        AddToLog("Return to lobby timer reached - returning to lobby to restart")
        ClickReturnToLobby()
        CheckLobby()
    } else {
        if (AutoRetry.Value) {
            AddToLog("Auto Retry enabled - skipping replay click")
        } else {
            ClickReplay()
        }
    }
    return
}

HandleDefaultMode() {
    global lastResult
    if (ShouldReturnToLobby()) {
        AddToLog("Return to lobby timer reached - returning to lobby to restart")
        ClickReturnToLobby()
        CheckLobby()
    } else if (lastResult = "win" && NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else {
        if (AutoRetry.Value) {
            AddToLog("Auto Retry enabled - skipping replay click")
        } else {
            ClickReplayPixel()
        }
    }
    return
}

HandleInfinityCastle() {
    global lastResult
    if (ShouldReturnToLobby()) {
        AddToLog("Return to lobby timer reached - returning to lobby to restart")
        ClickReturnToLobby()
        CheckLobby()
    } else if (lastResult = "win" && NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else {
        if (AutoRetry.Value) {
            AddToLog("Auto Retry enabled - skipping replay click")
        } else {
            ClickReplay()
        }
    }
    return
}

ShouldReturnToLobby() {
    global ReturnToLobbyStartTime
    remaining := GetReturnToLobbyTimer() - (A_TickCount - ReturnToLobbyStartTime)

    if (ModeDropdown.Text = "Custom" || ModeDropdown.Text = "Boss Rush" || ModeDropdown.Text = "Adventure Mode") {
        return false
    }

    if (GetReturnToLobbyTimer() > 0 && remaining <= 0) {
        return true
    }
    if (remaining > 0) {
        FormatTimeLeft(remaining)
    }
    return false
}

HandleRangerMode() {
    remaining := GetReturnToLobbyTimer() - (A_TickCount - ReturnToLobbyStartTime)
    if (ReplayBox.Visible && ReplayBox.Value && ModeDropdown.Text != "Cid") {
        if (GetReturnToLobbyTimer() > 0) {
            if (remaining <= 0) {
                AddToLog("Return to lobby timer reached - returning to lobby to restart")
                ClickReturnToLobby()
                CheckLobby()
            } else {
                ; Optional: Only log every minute or with throttling
                FormatTimeLeft(remaining)
            }
        } else {
            ClickReplayRanger()
        }

    } else {
        ClickReturnToLobby()
        CheckLobbyRanger() ; call directly, no return
    }
    return
}

HandlePortalMode() {
    if (ModeDropdown.Text == "Portal") {
        if (CanReplay()) {
            ClickReplay()
        } else {
            if (GetMapForFarming(PortalDropdown.Text) != "no map found") {
                SwitchActiveFarm()
                Sleep(1500)
                ClickReturnToLobby()
                CheckLobby()
            } else {
                AddToLog("No map found for farming in Portal mode.")
                ClickReturnToLobby()
                CheckLobby() ; call directly, no return
            }
        }
    }
}

OpenPlayMenu() {
    FixClick(25, 340)
    Sleep (1000)
}

RangerMovement() {
    FixClick(63, 329)
    Sleep (1000)
}

RaidMovement() {
    FixClick(63, 329)
    Sleep (1000)
}

BossEventMovement() {
    FixClick(775, 260) ; Click Boss Event
    Sleep (1000)
}

ChallengeCameraChange() {
    SendInput ("{Escape}") ; Close any open menus
    Sleep (1500)
    FixClick(252, 91) 
    Sleep (250)
    Loop 2 {
        FixClick(339, 204)  
        Sleep (100)
    }
    SendInput ("{Escape}")
    Sleep (1500)

    loop 2 {
        FixClick(26, 330) ; Click Areas
        Sleep (300)
        FixClick(361, 226)  
        Sleep (300)
        FixClick(26, 330) ; Click Areas
        Sleep (300)
        FixClick(518, 228)
        Sleep (300)
    }

    SendInput ("{Escape}") ; Close any open menus
    Sleep (1500)
    FixClick(252, 91) ; Click Camera Change
    Sleep (250)
    Loop 2 {
        FixClick(339, 204) ; Click Camera Change
        Sleep (100)
    }
    SendInput ("{Escape}") ; Close any open menus
    Sleep (1500)
    
    SendInput ("{Tab}") ; Close Lederboard

}

ChallengeMovement() {

    Sleep (250)
    SendInput ("{d down}")
    Sleep (500)
    SendInput ("{d up}")
    Sleep (250)
    SendInput ("{w down}")
    Sleep (350)
    SendInput ("{w up}")
    Sleep (250)
    SendInput ("{d down}")
    Sleep (1000)
    SendInput ("{d up}")
    Sleep (250)
    SendInput ("{w down}")
    Sleep (300)
    SendInput ("{w up}")
    Sleep (250)
    SendInput ("{d down}")
    Sleep (5000)
    SendInput ("{d up}")
    Sleep (250)
    SendInput ("{a down}")
    Sleep (1000)
    SendInput ("{a up}")
    Sleep (250)
    SendInput ("{w down}")
    Sleep (3000)
    SendInput ("{w up}")
    Sleep (250)
    loop 2 {
        SendInput ("{e}")
        Sleep (100)
    }
    Sleep (1000)
}

StartRanger(map, act, isRanger := false) {
    if (ShouldSkipMap(map, act)) {
        AddToLog("Map Skips: Skipping " map " - " act)
        return false
    }

    AddToLog("Selecting map: " map " and act: " act)

    StoryMap := GetMapData("LegendMap", map)
    if (!StoryMap.HasOwnProp("x") || !StoryMap.HasOwnProp("y")) {
        AddToLog("❌ Map data not found for: " map)
        return false
    }

    FixClick(398, 469) ; Click on Ranger Stage
    Sleep(200)
    FixClick(230, 191) 
    Sleep(100)
    loop 3 {
        SendInput("{WheelUp}")
        Sleep(250)
    } 

    if (StoryMap.HasOwnProp("scrolls") && StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(230, 175)
        loop StoryMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)

    if (isRanger) {
        Sleep(2000)
        FixClick(468, 469)
        Sleep(200)
    }
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)

    StoryAct := GetMapData("LegendAct", act)
    if (!StoryAct.HasOwnProp("x") || !StoryAct.HasOwnProp("y")) {
        AddToLog("❌ Act data not found for: " act)
        return false
    }

    if (isRanger) {
        Sleep(2000)
    }
    if (StoryAct.HasOwnProp("scrolls") && StoryAct.scrolls > 0) {
        AddToLog("Scrolling down " StoryAct.scrolls " times for " act)
        MouseMove(400, 175)
        loop StoryAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)

    FixClick(StoryAct.x, StoryAct.y)
    Sleep(1000)

    return true
}

GetMapData(type, name) {
    data := Map(
        "StoryMap", Map(
            "Voocha Village", {x: 230, y: 165, scrolls: 0},
            "Green Planet", {x: 230, y: 230, scrolls: 0},
            "Demon Forest", {x: 230, y: 290, scrolls: 0},
            "Leaf Village", {x: 230, y: 360, scrolls: 0},
            "Z City", {x: 235, y: 270, scrolls: 1},
            "Ghoul City", {x: 236, y: 345, scrolls: 1},
            "Night Colosseum",{x: 237, y: 316, scrolls: 2},
            "Bizzare Race", {x: 233, y: 379, scrolls: 2}
        ),
        "StoryAct", Map(
            "Act 1", {x: 400, y: 180, scrolls: 0},
            "Act 2", {x: 400, y: 245, scrolls: 0},
            "Act 3", {x: 400, y: 300, scrolls: 0},
            "Act 4", {x: 400, y: 225, scrolls: 1},
            "Act 5", {x: 400, y: 275, scrolls: 1},
            "Act 6", {x: 400, y: 200, scrolls: 2},
            "Act 7", {x: 400, y: 250, scrolls: 2},
            "Act 8", {x: 400, y: 300, scrolls: 2},
            "Act 9", {x: 400, y: 235, scrolls: 3},
            "Act 10", {x: 400, y: 290, scrolls: 3},
        ),
        "RaidMap", Map(
            "Steel Blitz Rush", {x: 233, y: 173, scrolls: 0}
        ),
        "RaidAct", Map(
            "Act 1", {x: 403, y: 191, scrolls: 0},
            "Act 2", {x: 404, y: 245, scrolls: 0},
            "Act 3", {x: 406, y: 305, scrolls: 0},
            "Act 4", {x: 406, y: 305, scrolls: 1}
        ),
        "LegendMap", Map(
            "Voocha Village", {x: 230, y: 165, scrolls: 0},
            "Green Planet", {x: 230, y: 230, scrolls: 0},
            "Demon Forest", {x: 230, y: 290, scrolls: 0},
            "Leaf Village", {x: 230, y: 360, scrolls: 0},
            "Z City", {x: 235, y: 270, scrolls: 1},
            "Ghoul City", {x: 230, y: 360, scrolls: 1},
            "Night Colosseum",{x: 227, y: 371, scrolls: 2}
        ),
        "LegendAct", Map(
            "Act 1", {x: 400, y: 180, scrolls: 0},
            "Act 2", {x: 400, y: 245, scrolls: 0},
            "Act 3", {x: 400, y: 300, scrolls: 0},
            "Act 4", {x: 400, y: 225, scrolls: 1},
            "Act 5", {x: 400, y: 275, scrolls: 1},
            "Act 6", {x: 400, y: 200, scrolls: 2},
            "Act 7", {x: 400, y: 250, scrolls: 2},
            "Act 8", {x: 400, y: 300, scrolls: 2},
            "Act 9", {x: 400, y: 235, scrolls: 3},
            "Act 10", {x: 400, y: 290, scrolls: 3},
            "Random", GetRandomAct()
        )
    )

    return data.Has(type) && data[type].Has(name) ? data[type][name] : {}
}

GetLegendMap(map) {
    switch map {
        case "Voocha Village": return { x: 230, y: 165, scrolls: 0 }
        case "Green Planet": return { x: 230, y: 230, scrolls: 0 }
        case "Demon Forest": return { x: 230, y: 290, scrolls: 0 }
        case "Leaf Village": return { x: 230, y: 360, scrolls: 0 }
        case "Z City": return { x: 235, y: 270, scrolls: 1 }
        case "Ghoul City": return { x: 230, y: 360, scrolls: 1 }
        case "Night Colosseum": return { x: 227, y: 371, scrolls: 2 }
    }
}

GetLegendAct(act) {
    switch act {
        case "Act 1": return { x: 400, y: 180, scrolls: 0 }
        case "Act 2": return { x: 400, y: 245, scrolls: 0 }
        case "Act 3": return { x: 400, y: 300, scrolls: 0 }
        case "Act 4": return { x: 400, y: 225, scrolls: 1 }
        case "Act 5": return { x: 400, y: 275, scrolls: 1 }
        case "Act 6": return { x: 400, y: 200, scrolls: 2 }
        case "Act 7": return { x: 400, y: 250, scrolls: 2 }
        case "Act 8": return { x: 400, y: 300, scrolls: 2 }
        case "Act 9": return { x: 400, y: 235, scrolls: 3 }
        case "Act 10": return { x: 400, y: 290, scrolls: 3 }
        case "Random": return GetRandomAct()
    }
}

GetRandomAct() {
    randomAct := Random(1, 3) ; Generates a random number between 1 and 3
    return {x: 285, y: 235 + (randomAct - 1) * 35, scrolls: 0}
}

StartLegend(map, act) {
    AddToLog("Selecting map: " map " and act: " act)

    FixClick(22, 227) ; Create Room
    Sleep(1000)

    FixClick(476, 466) ; Click Legend Stages
    Sleep(1000)

    ; Get Legend Stage Map 
    LegendMap := GetMapData("LegendMap", map)
    
    ; Scroll if needed
    if (LegendMap.scrolls > 0) {
        AddToLog("Scrolling down " LegendMap.scrolls " for " map)
        MouseMove(230, 175)
        loop LegendMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(LegendMap.x, LegendMap.y)
    Sleep(1000)
    
    ; Get act details
    LegendAct := GetMapData("LegendAct", act)
    
    ; Scroll if needed for act
    if (LegendAct.scrolls > 0) {
        AddToLog("Scrolling down " LegendAct.scrolls " times for " act)
        MouseMove(400, 175)
        loop LegendAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(LegendAct.x, LegendAct.y)
    Sleep(1000)
    
    return true
}

PlayHere() {
    global inChallengeMode, challengeMapIndex, challengeStageCount, challengeStartTime, startingMode

    FixClick(485, 410)  ;Create
    if (inChallengeMode) {
        Sleep (500)
        if (CheckForCooldownMessage()) {
            AddToLog("Still on cooldown...")
            FixClick(580, 410) ; Exit Ranger Stages
            Sleep (2000)
            FixClick(70, 325) ; Exit 
            inChallengeMode := false
            challengeMapIndex := 1  ; Reset map index for next session
            challengeStageCount := 0  ; Reset stage count for new ranger stage session

            CheckLobby()
            startingMode := true
            return
        }
    }
    Sleep (2500)


    FixClick(400, 475) ;Start
    inStage := true
    autoAbilityClicking := true
    Sleep (1200)
    startingMode := false
}

CreateChallenge() {
    global startingMode
    FixClick(284, 259) ; Click Create Challenge
    Sleep(1500)
    FixClick(400, 475) ;Start
    Sleep (1000)
    startingMode := false
}

StartBossEvent() {
    FixClick(450, 355) ; Click Play
    Sleep(1500)
}

StartPortal() {
    FixClick(160, 349) ; Click Use Portal
    Sleep(1000)
    FixClick(115, 323) ; Start
    Sleep(2000)
}

BasicSetup() {
    CloseChat()
    Sleep 300
}
    
RestartStage() {
    global currentMap, checkForUnitManager, lastHourCheck, inChallengeMode, startingMode, ReturnToLobbyStartTime

    loop {

        if (startingMode) {
            StartSelectedMode()
            continue ; immediately restart loop with new mode
        }

        checkForUnitManager := true

        ; Wait for loading
        WaitForGameState("loading")

        if (!AutoStart.Value) {
            ; Wait for game to actually start
            WaitForGameState("voting")

            ; Check for the vote start
            CheckForVoteScreen()
        }

        ; Set Game Speed
        if (!AutoGameSpeed.Value) {
            ChangeGameSpeed()
        }

        if (ModeDropdown.Text = "Infinity Castle" || ModeDropdown.Text = "Boss Rush") {
            SetTimer(ChangePath, GetPathChangetimer())
        }

        ; Close Leaderboard
        FixClick(487, 71)

        ; Summon Units
        SummonUnits()
        
        ; Monitor stage progress
        MonitorEndScreen()

    }
}

Reconnect() {

    ;Credit: @Haie
    color_home := PixelGetColor(10, 10)
    color_reconnect := PixelGetColor(519,329)
    if (color_home == 0x121215 or color_reconnect == 0x393B3D) {
        AddToLog("Disconnected! Attempting to reconnect...")
        ;sendDCWebhook()

        if (AutoAbility.Value) {
            SetTimer(CheckAutoAbility, 0)
        }

        try {
            if (WinExist(rblxID)) { 
                WinActivate(rblxID)
            }
        } catch {
            if (debugMessages) {
                AddToLog("Error: Unable to activate Roblox window.")
            }
        }

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

        ; Reconnect to Ps
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddToLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=" 72829404259339)
        }

        Sleep 2000
        loop {
            FixClick(490, 400)
            AddToLog("Reconnecting to Roblox...")
            Sleep 5000
            if WinExist(rblxID) {
                WinActivate(rblxID)
                forceRobloxSize()
                moveRobloxWindow()
                Sleep (2000)
            }
            if (ok := GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                ; Reset all mode-related variables to restart the sequence
                global firstStartup := true
                global inChallengeMode := false, challengeStartTime := A_TickCount, challengeMapIndex := 1, challengeStageCount := 0
                global currentMap := ""
                ; startingMode will be true if CheckLobby was called, or StartSelectedMode will handle it via firstStartup
                AddToLog("All modes reset. Restarting sequence.")
                return StartSelectedMode()
            } else {
				FixClick(560, 174)
                Reconnect() 
            }
        }
    }
}

RejoinPrivateServer(testing := false) {   
    AddToLog("Attempting to reconnect to Anime Rangers X...")

    psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""

    if psLink {
        AddToLog("Connecting to private server...")
        Run(psLink)
    } else {
        Run("roblox://placeID=" 72829404259339)
    }

    Sleep(5000)

    ; Loop until successfully reconnected
    loop {
        AddToLog("Reconnecting to Roblox...")
        Sleep(5000)

        if WinExist(rblxID) {
            forceRobloxSize()
            moveRobloxWindow()
            Sleep(1000)
        }

        if (ok := GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)) {
            AddToLog("Reconnected Successfully!")
            if (!testing) {
                ; Reset all mode-related variables to restart the sequence
                global firstStartup := true
                global inChallengeMode := false, challengeStartTime := A_TickCount, challengeMapIndex := 1, challengeStageCount := 0
                global currentMap := ""
                ; startingMode will be true if CheckLobby was called, or StartSelectedMode will handle it via firstStartup
                AddToLog("All modes reset. Restarting sequence.")
                return StartSelectedMode()
            } else {
                return
            }
        }
		FixClick(560, 174)
        Reconnect()
    }
}


CheckForXp() {
    ; Check for lobby text
    if (ok := GetFindText().FindText(&X, &Y, 118, 180, 219, 216, 0.10, 0.10, GameEnded)) {
        return true
    }
    return false
}

CheckLobby() {
    global currentMap, startingMode, ReturnToLobbyStartTime

    loop {
        if (ok := GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)) {
            break
        }
        if (CheckForXp()) {
            AddToLog("Detected end game screen when should have already returned to lobby")
            MonitorEndScreen() ; No need for `return` here
            return ; Exit CheckLobby after handling MonitorEndScreen
        }
        Reconnect()
        Sleep(1000)
    }

    AddToLog("Returned to lobby, restarting selected mode")
    Sleep(SleepTime())
    currentMap := ""
    startingMode := true
    ReturnToLobbyStartTime := A_TickCount
}

CheckLobbyRanger() {
    global currentMap, startingMode

    loop {
        if (ok := GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)) {
            break
        }
        if (CheckForXp()) {
            AddToLog("Detected end game screen when should have already returned to lobby")
            MonitorEndScreen() ; No need for `return` here
            return ; Exit CheckLobby after handling MonitorEndScreen
        }
        Reconnect()
        Sleep(1000)
    }

    AddToLog("Returned to lobby")
    Sleep(SleepTime())
    currentMap := ""
    startingMode := true
}

CheckLoaded() {
    global checkForUnitManager
    startTime := A_TickCount
    timeout := 120 * 1000 ; Convert to milliseconds

    loop {
        Sleep(1000)

        if (checkForUnitManager) {
            if (ok := FindText(&X, &Y, 609, 463, 723, 495, 0.10, 0.20, UnitManagerBack)) {
                AddToLog("Unit Manager found, game is loaded.")
                checkForUnitManager := false
                break
            }
        }
        
        if (GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
            AddToLog("Successfully Loaded In: Vote screen was found.")
            break
        } else if (PixelGetColor(381, 47, "RGB") = 0x5ED800) {
            AddToLog("Successfully Loaded In: Base health was found.")
            break
        } else if (GetFindText().FindText(&X, &Y, 12, 594, 32, 615, 0.05, 0.10, InGameSettings)) {
            AddToLog("Successfully Loaded In: Settings cogwheel was found.")
            break
        }

        ; Failsafe check
        if (A_TickCount - startTime > timeout) {
            AddToLog("Failed to load within 2 minutes. Rejoining the game.")
            return RejoinPrivateServer()
        }

        ClickThroughDrops()

        Reconnect()
    }
}

StartedGame() {
    global stageStartTime

    ; Record the start time for the 2-second wait period
    startTime := A_TickCount
    foundVote := false
    timeoutTime := GetVoteTimeoutTime()

    loop {
        ; Sleep for a shorter period (e.g., 100ms) to keep checking within 2 seconds
        Sleep(100)

        ; Check if the vote screen is still visible
        if (ok := GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
            ; Click to fix the vote screen if it's visible
            FixClick(400, 150)
            
            ; Reset the timer if it's still visible
            startTime := A_TickCount
            foundVote := true
            continue  ; Keep waiting if vote screen is still there
        }
        
        ; If the vote screen is no longer visible / was not found
        if (A_TickCount - startTime >= timeoutTime) {
            FixClick(400, 150) ; For those who can't follow a simple setup guide
            AddToLog("Game started")
            stageStartTime := A_TickCount
            break
        }

        if (foundVote) {
            FixClick(400, 150) ; For those who can't follow a simple setup guide
            AddToLog("Game started")
            stageStartTime := A_TickCount
            break
        }
    }
}

WaitForGameState(mode := "loading") {
    global checkForUnitManager, stageStartTime, Wins, loss

    inStage := false
    autoAbilityClicking := false

    startTime := A_TickCount
    voteSeen := false
    timeout := (mode = "loading") ? 120000 : GetVoteTimeoutTime()

    loop {
        Sleep((mode = "loading") ? 1000 : 100)

        if (mode = "loading" && !IsInLobby()) {
            if (checkForUnitManager) {
                if (FindText(&X, &Y, 609, 463, 723, 495, 0.10, 0.20, UnitManagerBack)) {
                    AddToLog("Loaded into the game: Unit manager was detected")
                    checkForUnitManager := false
                    break
                }
            }

            if (GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
                AddToLog("Loaded into the game: Vote screen was detected")
                break
            } else if (GetPixel(0x6DE000, 454, 46, 2, 2, 10)) {
                AddToLog("Loaded into the game: Base health was detected")
                break
            } else if (GetFindText().FindText(&X, &Y, 12, 594, 32, 615, 0.05, 0.10, InGameSettings)) {
                AddToLog("Loaded into the game: Settings cogwheel was detected")
                break
            }

            ; Failsafe timeout
            if (A_TickCount - startTime > timeout) {
                AddToLog("Failed to load within 2 minutes. Rejoining the game.")
                return RejoinPrivateServer()
            }

            ClickThroughDrops()
            Reconnect()

        } else if (mode = "voting") {
            ; Wait for vote screen to disappear
            if (AutoStart.Value) {
                AddToLog("Game started (Auto Start enabled) Total Runs: " Wins + loss)
                stageStartTime := A_TickCount
                break
            }
            if (GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
                FixClick(400, 150)
                voteSeen := true
                startTime := A_TickCount
                continue
            }

            ; Vote screen has disappeared
            if (A_TickCount - startTime >= timeout || voteSeen) {
                FixClick(400, 150)
                AddToLog("Game started")
                stageStartTime := A_TickCount
                break
            }
        }
    }
}

StartSelectedMode() {
    global inChallengeMode, firstStartup, challengeStartTime, currentMap, startingMode

    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)

    FixClick(558, 166) ; Closes Daily
    Sleep(500)

    if (firstStartup) {
        firstStartup := false 
    }
    
    AddToLog("Starting mode: " ModeDropdown.Text)
    switch ModeDropdown.Text {
        case "Story":
            StartContent(StoryDropdown.Text, StoryActDropdown.Text, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
        case "Ranger Stages":
            StartContent(RangerMapDropdown.Text, RangerActDropdown.Text, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
        case "Raid":
            StartContent(RaidDropdown.Text, RaidActDropdown.Text, GetRaidMap, GetRaidAct, { x: 230, y: 155 }, { x: 405, y: 195 })
        case "Boss Event":
            BossEvent()
        case "Challenge":
            ChallengeMode()
        case "Portal":
            Portal()
        case "Infinity Castle":
            StartInfinityCastle()
        case "Boss Rush":
            StartBossRush()
        case "Swarm Event":
            StartSwarmEvent()   
        case "Adventure Mode":
            startingMode := false
        case "Custom":
            CoOpMode()
    }
}

VoteCheck() {
    global lastVoteCheck, voteCheckCooldown
    now := A_TickCount
    if (now - lastVoteCheck > voteCheckCooldown) {
        CheckForVoteScreen()
        lastVoteCheck := now
    }
}

CoOpMode() {
    global startingMode
    startingMode := false
}

CanReplay() {
    if (GetFindText().FindText(&X, &Y, 161, 351, 630, 522, 0, 0, Replay)) {
        return true
    }
    return false
}

IsInLobby() {
    return GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)
}

ChangePath() {
    AddToLog("Changing " ModeDropdown.Text " Path")
    FixClick(471, 439)
}

DoesntStartInLobby(ModeName) {
    ; Array of modes that usually start in lobby
    static modes := ["Custom", "Boss Rush", "Swarm Event", "Adventure Mode", "Infinity Castle"]

    ; Check if current mode is in the array
    for mode in modes {
        if (mode = ModeName)
            return true
    }
    return false
}