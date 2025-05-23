#Requires AutoHotkey v2.0
#Include Image.ahk

global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

global currentMap := ""
global checkForUnitManager := true
global lastHourCheck := A_Hour

global startingMode := true

LoadKeybindSettings()  ; Load saved keybinds
CheckForUpdates()
Hotkey(F1Key, (*) => moveRobloxWindow())    
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {
    SummonUnits()
}

F6:: {

}

F7:: {
    GetMousePos()
}

F8:: {
    Run (A_ScriptDir "\Lib\FindText.ahk")
}


StartMacro(*) {
    if (!ValidateMode()) {
        return
    }
    RestartStage()
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

StoryMode() {
    global startingMode
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := GetFindText().FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }

    FixClick(25, 225) ; Create Room
    Sleep(1000)

    while !(ok := GetFindText().FindText(&X, &Y, 325, 163, 409, 193, 0.05, 0.20, StoryChapter)) {
        AddToLog("Looking for Story Chapter Text...")
        FixClick(615, 155) ; Click X on Join
        Sleep(1000)
        FixClick(25, 225) ; Create Room
        Sleep(1000)
        Reconnect() ; Added Disconnect Check
    }

    AddToLog("Starting " currentStoryMap " - " currentStoryAct)
    StartStory(currentStoryMap, currentStoryAct)

    PlayHere()
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
    ChallengeMovement()

    while !(ok := GetFindText().FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        Reconnect() ; Added Disconnect Check
        FixClick(598, 425) ; Click Back
        ChallengeMovement()
    }

    CreateChallenge()
}

CoopMode() {
    global startingMode
    
    startingMode := false
}

EasterEvent() {
    global startingMode
    EasterMovement()

    while !(ok := GetFindText().FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        Reconnect() ; Added Disconnect Check
        FixClick(598, 425) ; Click Back
        EasterMovement()
    }

    CreateChallenge()
    startingMode := false
}


LegendMode() {
    global challengeMapIndex, challengeMapList, challengeStageCount, inChallengeMode, startingMode

    ; Keep skipping until a valid map is found or end of list
    while (challengeMapIndex <= challengeMapList.Length && ShouldSkipMap(challengeMapList[challengeMapIndex])) {
        AddToLog(challengeMapList[challengeMapIndex] " is set to be skipped. Skipping...")
        challengeMapIndex++
        Sleep(1000)
    }

    ; Check if we ran out of maps
    if (challengeMapIndex > challengeMapList.Length) {
        AddToLog("No more valid maps to run.")
        inChallengeMode := false
        challengeStartTime := A_TickCount  ; Reset timer for next ranger stage trigger
        challengeMapIndex := 1  ; Reset map index for next session
        challengeStageCount := 0  ; Reset stage count for new ranger stage session
        CheckLobby()
        startingMode := true
        return
    }

    currentLegendMap := challengeMapList[challengeMapIndex]
    currentLegendAct := "Act 1"
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := GetFindText().FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        if (debugMessages) {
            AddToLog("Debug: Looking for create room text...")
        }
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
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

RaidMode() {
    global RaidDropdown, RaidActDropdown, startingMode
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)

    
    ; Start stage
    while !(ok := GetFindText().FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check

    }
    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)

    PlayHere()
}

MonitorEndScreen() {
    global challengeStartTime, inChallengeMode, challengeStageCount, challengeMapIndex, challengeMapList
    global Wins, loss, stageStartTime, lastResult, webhookSendTime, firstWebhook

    isWin := false

    ; Wait for XP to appear or reconnect if necessary
    while !CheckForXp() {
        ClickThroughDrops()
        Reconnect()
        Sleep(1000)
    }

    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    CloseChat()

    ; Detect win or loss
    if (GetFindText().FindText(&X, &Y, 377, 228, 536, 276, 0.05, 0.80, DefeatText)) {
        isWin := false
    } else if (GetFindText().FindText(&X, &Y, 397, 222, 538, 273, 0.05, 0.80, VictoryText)) {
        isWin := true
    }

    lastResult := isWin ? "win" : "lose"
    AddToLog((isWin ? "Victory" : "Defeat") " detected - Stage Length: " stageLength)
    (isWin ? Wins += 1 : loss += 1)
    Sleep(1000)

    if (firstWebhook || (A_TickCount - webhookSendTime) >= GetWebhookDelay()) {
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

    ; ─── End-of-Stage Handling ───
    if (inChallengeMode) {
        challengeStageCount++
        AddToLog("Completed " challengeStageCount " out of 3 ranger stages for " challengeMapList[challengeMapIndex])

        if (challengeStageCount >= 3) {
            AddToLog("Completed all 3 ranger stages for " challengeMapList[challengeMapIndex])
            challengeStageCount := 0
            challengeMapIndex++

            if (challengeMapIndex > challengeMapList.Length) {
                AddToLog("All maps completed, returning to " ModeDropdown.Text)
                inChallengeMode := false
                challengeStartTime := A_TickCount
                challengeMapIndex := 1
                ClickReturnToLobby()
                CheckLobby()
                return
            } else {
                AddToLog("Returning to lobby to start next map: " challengeMapList[challengeMapIndex])
                ClickReturnToLobby()
                CheckLobby()
                return
            }
        } else {
            ClickNextLevel()
            return
        }
    }

    ; ─── Start Challenge Mode If Time ───
    if (!inChallengeMode && ChallengeBox.Value) {
        if ((A_TickCount - challengeStartTime) >= 1800000) {
            AddToLog("30 minutes has passed - switching to Ranger Stages")
            inChallengeMode := true
            challengeStartTime := A_TickCount
            challengeStageCount := 0
            ClickReturnToLobby()
            CheckLobby()
            return
        }
    }

    ; ─── Mode Handling ───
    if (ModeDropdown.Text = "Story") {
        HandleStoryMode()
    } else {
        HandleDefaultMode()
    }
}


HandleStoryModeOld() {
    global lastResult

    if (lastResult "win" && NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else {
        ClickReplay()
    }
    return RestartStage()
}

HandleDefaultModeOld() {
    if (ReturnLobbyBox.Visible && ReturnLobbyBox.Value && ModeDropdown.Text != "Coop") {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        ClickReplay()
    }
    return RestartStage()
}

HandleStoryMode() {
    global lastResult

    if (lastResult = "win" && NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else {
        ClickReplay()
    }
    ; Don't return a function call — let control go back to MainLoop
    return
}

HandleDefaultMode() {
    if (ReturnLobbyBox.Visible && ReturnLobbyBox.Value && ModeDropdown.Text != "Coop") {
        ClickReturnToLobby()
        CheckLobby() ; call directly, no return
    } else {
        ClickReplay()
    }
    return
}

HandleLegendMode() {
    global lastHourCheck

    currentHour := A_Hour
    currentTime := A_Hour ":" A_Min ":" A_Sec

    if (debugMessages) {
        AddToLog("HandleLegendMode() called at " currentTime)
    }

    ; If a new hour has started
    if (currentHour != lastHourCheck) {
        if (debugMessages) {
            AddToLog("New hour detected (last: " lastHourCheck ", now: " currentHour ") - returning to lobby")
        }
        lastHourCheck := currentHour
        ClickReturnToLobby()
        CheckLobby()
        return
    }

    if (ReturnLobbyBox.Visible && ReturnLobbyBox.Value) {
        ClickReturnToLobby()
        CheckLobby()
        return
    } else {
        ClickReplay()
    }
    return
}


StoryMovement() {
    FixClick(65, 335)
    Sleep (200)
    FixClick(400, 300)
    Sleep (1000)
}

BossEventMovement() {
    FixClick(775, 260) ; Click Boss Event
    Sleep (1000)
}

ChallengeMovement() {
    FixClick(25, 325) ; Click Areas
    Sleep (1000)
    FixClick(357, 287) ; Teleport to Challenges
    Sleep (1000)
    SendInput ("{a down}")
    Sleep (1500)
    SendInput ("{a up}")
}

EasterMovement() {
    FixClick(25, 325) ; Click Areas
    Sleep (1000)
    FixClick(357, 225) ; Teleport To Lobby
    Sleep (1000)
    SendInput ("{s down}")
    Sleep (1000)
    SendInput ("{s up}")
    KeyWait ("s")
    Sleep (1000)
    SendInput ("{d down}")
    Sleep (1000)
    SendInput ("{d up}")
    KeyWait ("d")
    Sleep (1000)
    SendInput ("{E}")
    Sleep (2000)
    if (GetFindText().FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        AddToLog("Correct angle, starting Easter...")
    } else {
        AddToLog("Wrong spawn angle, retrying...")
        FixClick(25, 325) ; Click Areas
        Sleep (1000)
        FixClick(357, 225) ; Teleport To Lobby
        Sleep (1000)
        SendInput ("{w down}")
        Sleep (1000)
        SendInput ("{w up}")
        KeyWait ("w")
        Sleep (1000)
        SendInput ("{a down}")
        Sleep (1000)
        SendInput ("{a up}")
        KeyWait ("a")
        Sleep (1000)
        SendInput ("{s down}")
        Sleep (200)
        SendInput ("{s up}")
        KeyWait ("s")
        Sleep (1000)
        SendInput ("{E}")
        Sleep (2000)
    }
}

StartStory(map, act) {
    AddToLog("Selecting map: " map " and act: " act)

    ; Get Story map 
    StoryMap := GetMapData("StoryMap", map)
    
    ; Scroll if needed
    if (StoryMap.scrolls > 0) {
        AddToLog("Scrolling down " StoryMap.scrolls " for " map)
        MouseMove(230, 175)
        loop StoryMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetMapData("StoryAct", act)
    
    ; Scroll if needed for act
    if (StoryAct.scrolls > 0) {
        AddToLog("Scrolling down " StoryAct.scrolls " times for " act)
        MouseMove(400, 175)
        loop StoryAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(StoryAct.x, StoryAct.y)
    Sleep(1000)

    FixClick(615, 250) ; Click nightmare
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
            "Z City", {x: 230, y: 360, scrolls: 1}
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
            "Ant Kingdom", {x: 630, y: 250, scrolls: 0}
        ),
        "RaidAct", Map(
            "Act 1", {x: 285, y: 235, scrolls: 0},
            "Act 2", {x: 285, y: 270, scrolls: 0},
            "Act 3", {x: 285, y: 305, scrolls: 0},
            "Act 4", {x: 285, y: 340, scrolls: 0},
            "Act 5", {x: 285, y: 375, scrolls: 0}
        ),
        "LegendMap", Map(
            "Voocha Village", {x: 230, y: 165, scrolls: 0},
            "Green Planet", {x: 230, y: 230, scrolls: 0},
            "Demon Forest", {x: 230, y: 290, scrolls: 0},
            "Leaf Village", {x: 230, y: 360, scrolls: 0},
            "Z City", {x: 230, y: 360, scrolls: 1}
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
            Sleep (1000)
            FixClick(70, 325) ; Exit 
            inChallengeMode := false
            challengeStartTime := A_TickCount  ; Reset timer for next ranger stage trigger
            challengeMapIndex := 1  ; Reset map index for next session
            challengeStageCount := 0  ; Reset stage count for new ranger stage session
            CheckLobby()
            startingMode := true
            return
        }
    }
    Sleep (1500)
    FixClick(400, 475) ;Start
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

StartRaid(map, act) {
    AddToLog("Selecting map: " map " and act: " act)

    ; Get Story map 
    RaidMap := GetMapData("RaidMap", map)
    
    ; Scroll if needed
    if (RaidMap.scrolls > 0) {
        AddToLog("Scrolling down " RaidMap.scrolls " for " map)
        MouseMove(700, 210)
        loop RaidMap.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the map
    FixClick(RaidMap.x, RaidMap.y)
    Sleep(1000)
    
    ; Get act details
    RaidAct := GetMapData("RaidAct", act)
    
    ; Scroll if needed for act
    if (RaidAct.scrolls > 0) {
        AddToLog("Scrolling down " RaidAct.scrolls " times for " act)
        MouseMove(300, 240)
        loop RaidAct.scrolls {
            SendInput("{WheelDown}")
            Sleep(250)
        }
    }
    Sleep(1000)
    
    ; Click on the act
    FixClick(RaidAct.x, RaidAct.y)
    Sleep(1000)
    
    return true
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100

    ; Zoom in smoothly
    Loop 10 {
        Send "{WheelUp}"
        Sleep 50
    }

    ; Look down
    Click
    MouseMove(400, 400)  ; Move mouse down to angle camera down
    
    ; Zoom back out smoothly
    Loop 20 {
        Send "{WheelDown}"
        Sleep 50
    }
    
    ; Move mouse back to center
    MouseMove(400, 300)
}

CloseChat() {
    if (ok := GetFindText().FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup() {
    CloseChat()
    Sleep 300
}

DetectMap(waitForLoadingScreen := false) {
    global lastHourCheck

    startTime := A_TickCount
    AddToLog("Trying to determine map...")

    mapPatterns := Map(
        "Voocha Village", VoochaVillage,
        "Green Planet", GreenPlanet,
        "Demon Forest", DemonForest,
        "Leaf Village", LeafVillage,
        "Z City", ZCity,
        "Cursed Town", CursedTown,
        "Egg Island", EggIsland
    )

    Loop {
        if (waitForLoadingScreen = true) {
            if (A_TickCount - startTime > GetLoadingScreenWaitTime()) {
                AddToLog("❌ No map was found after waiting " GetLoadingWaitInSeconds() " seconds.")
                lastHourCheck := A_Hour
                return "No Map Found"
            }
        } else {
            ; Timeout after 5 minutes
            if (A_TickCount - startTime > 300000) {
                if (ok := GetFindText().FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
                    AddToLog("Found in lobby - restarting selected mode")
                    return StartSelectedMode()
                }
                AddToLog("❌ Could not detect map after 5 minutes")
                return "No Map Found"
            }

            ; Check for vote screen
            if (ok := GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart) 
                or PixelGetColor(492, 47) = 0x5ED800) {
                AddToLog("❌ No map was found before loading in")
                return "No Map Found"
            }
        }
        ; Check for map
        for mapName, pattern in mapPatterns {
            if (ok := GetFindText().FindText(&X, &Y, 11, 159, 450, 285, 0, 0, pattern)) {
                AddToLog("✅ Map detected: " mapName)
                lastHourCheck := A_Hour
                return mapName
            }
        }
        Sleep 1000
        Reconnect()
    }
}
    
RestartStage() {
    global currentMap, checkForUnitManager, lastHourCheck, inChallengeMode, startingMode

    loop {

        if (startingMode) {
            StartSelectedMode()
            continue ; immediately restart loop with new mode
        }


        checkForUnitManager := true

        if (ModeDropdown.Text = "Challenge" && !inChallengeMode) {
            if (A_Hour != lastHourCheck) {
                AddToLog("New hour detected (last: " lastHourCheck ", now: " A_Hour ")")
                currentMap := DetectMap(true)  ; Force re-detect the map
            } else {
                if (currentMap = "") {
                    currentMap := DetectMap(false)  ; Detect once if not already known
                }
            }
        } else if (ModeDropdown.Text != "Coop") {
            if (currentMap = "") {
                currentMap := DetectMap(false)  ; Normal detect
            } else {
                AddToLog("Current Map: " currentMap)
            }
        }
        

        ; Wait for loading
        CheckLoaded()

        ; Wait for game to actually start
        StartedGame()

        ; Check for the vote start
        CheckForVoteScreen()

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
        sendDCWebhook()

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
            Sleep 15000
            if WinExist(rblxID) {
                WinActivate(rblxID)
                forceRobloxSize()
                moveRobloxWindow()
                Sleep (2000)
            }
            if (ok := GetFindText().FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode()
            } else {
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

        if (ok := GetFindText().FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
            AddToLog("Reconnected Successfully!")
            if (!testing) {
                return StartSelectedMode()
            } else {
                return
            }
        }

        Reconnect()
    }
}


CheckForXp() {
    ; Check for lobby text
    if (ok := GetFindText().FindText(&X, &Y, 118, 181, 219, 217, 0.05, 0.05, GameEnded)) {
        FixClick(560, 560)
        return true
    }
    return false
}

CheckLobbyOld() {
    global currentMap
    loop {
        if (ok := GetFindText().FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
            break
        }
        if (CheckForXp()) {
            AddToLog("Detected end game screen when should have already returned to lobby")
            return MonitorEndScreen()
        }
        Reconnect()
        Sleep (1000)
    }
    AddToLog("Returned to lobby, restarting selected mode")
    Sleep(SleepTime())
    currentMap := ""
    return StartSelectedMode()
}

CheckLobby() {
    global currentMap, startingMode

    loop {
        if (ok := GetFindText().FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
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
        
        ; If the vote screen is no longer visible and 2 seconds have passed
        if (A_TickCount - startTime >= 2000) {
            ; Click and proceed with game start logic after 2 seconds
            FixClick(400, 150) ; For those who can't follow a simple setup guide

            ; Game is started and properly loaded
            AddToLog("Game started")
            stageStartTime := A_TickCount
            break
        }

        ; If vote screen is found and we're inside the loop, break early
        if (foundVote) {
            FixClick(400, 150) ; For those who can't follow a simple setup guide
            AddToLog("Game started")
            stageStartTime := A_TickCount
            break
        }
    }
}

StartSelectedMode() {
    global inChallengeMode, firstStartup, challengeStartTime

    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)

    if (ModeDropdown.Text != "Coop") {
        if (ChallengeBox.Value && firstStartup) {
            AddToLog("Auto Ranger Stage enabled - starting with Ranger Stage")
            inChallengeMode := true
            firstStartup := false
            challengeStartTime := A_TickCount  ; Set initial challenge time
            LegendMode()
            return
        }
    }

    ; If we're in challenge mode, do challenge
    if (inChallengeMode) {
        AddToLog("Starting Ranger Stages")
        LegendMode()
        return
    }    
    else if (ModeDropdown.Text = "Story") {
        StoryMode()
    }
    else if (ModeDropdown.Text = "Boss Event") {
        BossEvent()
    }
    else if (ModeDropdown.Text = "Challenge") {
        ChallengeMode()
    }
    else if (ModeDropdown.Text = "Coop") {
        CoopMode()
    }
    else if (ModeDropdown.Text = "Easter Event") {
        EasterEvent()
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)
    
    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)
    
    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

ValidateMode() {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before starting the macro!")
        return false
    }
    if (!confirmClicked) {
        AddToLog("Please click the confirm button before starting the macro!")
        return false
    }
    return true
}

GetNavKeys() {
    return StrSplit(FileExist("Settings\UINavigation.txt") ? FileRead("Settings\UINavigation.txt", "UTF-8") : "\,#,}", ",")
}

IsColorInRange(color, targetColor, tolerance := 50) {
    ; Extract RGB components
    r1 := (color >> 16) & 0xFF
    g1 := (color >> 8) & 0xFF
    b1 := color & 0xFF
    
    ; Extract target RGB components
    r2 := (targetColor >> 16) & 0xFF
    g2 := (targetColor >> 8) & 0xFF
    b2 := targetColor & 0xFF
    
    ; Check if within tolerance range
    return Abs(r1 - r2) <= tolerance 
        && Abs(g1 - g2) <= tolerance 
        && Abs(b1 - b2) <= tolerance
}

SleepTime() {
    time := [0, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000]  ; Array of sleep values
    timeIndex := LobbySleepTimer.Value  ; Get the selected speed value

    if timeIndex is number  ; Ensure it's a number
        return time[timeIndex]  ; Use the value directly from the array
}

GetLoadingScreenWaitTime() {
    time := [15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 60000]  ; Array of sleep values
    timeIndex := LoadingScreenWaitTime.Value  ; Get the selected speed value

    if timeIndex is number  ; Ensure it's a number
        return time[timeIndex]  ; Use the value directly from the array
}

GetLoadingWaitInSeconds() {
    ms := GetLoadingScreenWaitTime()
    return Round(ms / 1000, 1)  ; Return with 1 decimal place for precision
}

GetPlacementOrder() {
    placements := []

    Loop 6 {
        slotNum := A_Index
        order := "placement" slotNum
        order := %order%
        order := Integer(order.Text)
        placements.Push({slot: slotNum, order: order})
    }

    for i, _ in placements {
        j := i
        while (j > 1 && placements[j].order < placements[j - 1].order) {
            temp := placements[j]
            placements[j] := placements[j - 1]
            placements[j - 1] := temp
            j--
        }
    }

    orderedSlots := []
    for item in placements
        orderedSlots.Push(item.slot)

    return orderedSlots
}

SummonUnits() {
    global checkForUnitManager
    upgradeUnits := ShouldUpgradeUnits.Value
    enabledSlots := []
    upgradeEnabledSlots := Map()
    waitUntilMaxSlots := Map()

    for slotNum in GetPlacementOrder() {
        enabledVar := "enabled" slotNum
        upgradeEnabledVar := "upgradeEnabled" slotNum
        upgradeBeforeSummonVar := "upgradeBeforeSummon" slotNum

        enabled := %enabledVar%
        upgradeEnabled := %upgradeEnabledVar%
        upgradeBeforeSummon := %upgradeBeforeSummonVar%

        if (enabled.Value) {
            enabledSlots.Push(slotNum)
            if (upgradeEnabled.Value) {
                upgradeEnabledSlots[slotNum] := true
                waitUntilMaxSlots[slotNum] := upgradeBeforeSummon.Value
            }
        }
    }

    if (enabledSlots.Length = 0) {
        if (debugMessages) {
            AddToLog("No units enabled - monitoring stage")
        }
        return
    }

    profilePoints := UnitProfilePoints(enabledSlots.Length)

    if (!AutoPlay.Value && !upgradeUnits) {
        AddToLog("Auto summon and auto upgrade is disabled - monitoring stage")
        checkForUnitManager := false
        return
    }

    ; Open Unit Manager if needed
    if (upgradeUnits && checkForUnitManager) {
        if (!GetFindText().FindText(&X, &Y, 609, 463, 723, 495, 0.10, 0.20, UnitManagerBack)) {
            AddToLog("Unit Manager isn't open - trying to open it")
            Loop {
                CheckForVoteScreen()
                if (!GetFindText().FindText(&X, &Y, 609, 463, 723, 495, 0.10, 0.20, UnitManagerBack)) {
                    SendInput("{T}")
                    FixClick(750, 330)
                    Sleep(1000)
                } else {
                    AddToLog("Unit Manager is open")
                    checkForUnitManager := false
                    break
                }
            }
        }
    }

    lastScrollGroup := ""
    lastSlotNum := ""

    ; Main loop — runs until all enabled slots are processed
    while (enabledSlots.Length > 0) {
        ; Track whether any upgrading was done this loop
        upgradedThisLoop := false
    
        ; Handle upgrading (only one unit at a time if toggle is on)
        if (upgradeUnits && upgradeEnabledSlots.Count > 0) {
            for index, slotNum in enabledSlots {
                if !upgradeEnabledSlots.Has(slotNum)
                    continue
    
                if CheckForXp() {
                    return
                }
    
                ; Scroll if needed
                if ([1, 2, 3].Has(slotNum))
                    currentGroup := "top"
                else
                    currentGroup := "bottom"
    
                if (currentGroup != lastScrollGroup) {
                    FixClick(660, 155)
                    (currentGroup = "top") ? ScrollToTop() : ScrollToBottom()
                    lastScrollGroup := currentGroup
                    Sleep(200)
                }
    
                profile := profilePoints[slotNum]
    
                if (slotNum != lastSlotNum) {
                    FixClick(profile.x, profile.y)
                    lastSlotNum := slotNum
                }

                ; Perform one upgrade loop
                loop UpgradeClicks.Value {
                    FixClick(70, 355)
                    Sleep(50)
                }

                upgradedThisLoop := true

                if (MaxUpgraded()) {
                    AddToLog("Max upgrade reached for slot: " slotNum)
                    FixClick(250, 200)
                    upgradeEnabledSlots.Delete(slotNum)
                }

                ; Break if we're only doing one unit at a time
                if (UpgradeUntilMaxed.Value)
                    break
            }
        }
    
        ; Now summon all enabled units
        for _, slotNum in enabledSlots {
            ; If the "Upgrade Before Summon" checkbox is enabled, wait until maxed before summoning
            if (!upgradeEnabledSlots.Has(slotNum) || (waitUntilMaxSlots.Has(slotNum) && !waitUntilMaxSlots[slotNum])) {
                if (AutoPlay.Value) {
                    SendInput("{" slotNum "}")
                }
            } else {
                if (debugMessages) {
                    AddToLog("Skipping summon for slot " slotNum " — waiting until maxed")
                }
            }
        }
    
        Reconnect()
        Sleep(500)
    
        ; Exit if upgrades are done and AutoPlay is on
        if (upgradeEnabledSlots.Count = 0 && !AutoPlay.Value) {
            AddToLog("All units have been upgraded to max, monitoring stage...")
            return
        }
    }    
}

MaxUpgraded() {
    Sleep 500
    ; Check for max text
    if (ok := GetFindText().FindText(&X, &Y, 108, 246, 158, 263, 0, 0, UnitMaxText)) {
        return true
    }
    return false
}

UnitProfilePoints(enabledCount := 6) {
    topSlots := [
        { x: 635, y: 190 }, ; Slot 1
        { x: 635, y: 275 }, ; Slot 2
        { x: 635, y: 350 }  ; Slot 3
    ]

    ; Adjust bottom slot positions based on how many slots are enabled
    if (enabledCount <= 4) {
        bottomY := [365] ; Centered
    } else if (enabledCount = 5) {
        bottomY := [275, 365] ; Spread for 2
    } else {
        bottomY := [190, 275, 365] ; Evenly spread for 3
    }

    bottomSlots := []
    for index, y in bottomY {
        bottomSlots.Push({ x: 635, y: y })
    }

    return Map(
        1, topSlots[1],
        2, topSlots[2],
        3, topSlots[3],
        4, bottomSlots.Has(1) ? bottomSlots[1] : { x: 635, y: 275 },
        5, bottomSlots.Has(2) ? bottomSlots[2] : { x: 635, y: 275 },
        6, bottomSlots.Has(3) ? bottomSlots[3] : { x: 635, y: 275 }
    )
}