#Requires AutoHotkey v2.0
#Include Image.ahk

global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

global currentMap := ""
global shouldSkipWebhook := false

LoadKeybindSettings()  ; Load saved keybinds
Hotkey(F1Key, (*) => moveRobloxWindow())    
Hotkey(F2Key, (*) => StartMacro())
Hotkey(F3Key, (*) => Reload())
Hotkey(F4Key, (*) => TogglePause())

F5:: {

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
    StartSelectedMode()
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
    global StoryDropdown, StoryActDropdown
    
    ; Get current map and act
    currentStoryMap := StoryDropdown.Text
    currentStoryAct := StoryActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentStoryMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }

    FixClick(25, 225) ; Create Room
    Sleep(1000)

    while !(ok := FindText(&X, &Y, 325, 163, 409, 193, 0.05, 0.20, StoryChapter)) {
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
    RestartStage()
}

BossEvent() {    
    BossEventMovement()

    while !(ok := FindText(&X, &Y, 400, 375, 508, 404, 0.05, 0.20, BossPlayText)) {
        Reconnect() ; Added Disconnect Check
        BossEventMovement()
    }

    StartBossEvent()
    RestartStage()
}

ChallengeMode() {    
    ChallengeMovement()

    while !(ok := FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        Reconnect() ; Added Disconnect Check
        FixClick(598, 425) ; Click Back
        ChallengeMovement()
    }

    CreateChallenge()
    RestartStage()
}

EasterEvent() {    
    EasterMovement()

    while !(ok := FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
        Reconnect() ; Added Disconnect Check
        FixClick(598, 425) ; Click Back
        EasterMovement()
    }

    CreateChallenge()
    RestartStage()
}


LegendMode() {
    global challengeMapIndex, challengeMapList, challengeStageCount, inChallengeMode

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
        return CheckLobby()
    }

    currentLegendMap := challengeMapList[challengeMapIndex]
    currentLegendAct := "Act 1"
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        if (debugMessages) {
            AddToLog("Debug: Looking for create room text...")
        }
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }

    FixClick(25, 225) ; Create Room
    Sleep(1000)

    while !(ok := FindText(&X, &Y, 325, 163, 409, 193, 0.05, 0.20, StoryChapter)) {
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
    RestartStage()
}

RaidMode() {
    global RaidDropdown, RaidActDropdown
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)

    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check

    }
    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)

    PlayHere()
    RestartStage()
}

MonitorEndScreen() {
    global challengeStartTime, inChallengeMode, challengeStageCount, challengeMapIndex, challengeMapList
    global Wins, loss, stageStartTime, shouldSkipWebhook, lastResult, webhookSendTime

    isWin := false
    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    ; Wait for XP to appear or reconnect if necessary
    while !CheckForXp() {
        ClickThroughDrops()
        Reconnect()
        Sleep(1000)
    }

    CloseChat()

    ; Detect win or loss
    if (FindText(&X, &Y, 377, 228, 536, 276, 0.05, 0.80, DefeatText)) {
        isWin := false
    } else if (FindText(&X, &Y, 397, 222, 538, 273, 0.05, 0.80, VictoryText)) {
        isWin := true
    }

    lastResult := isWin ? "win" : "lose"
    AddToLog((isWin ? "Victory" : "Defeat") " detected - Stage Length: " stageLength)
    (isWin ? Wins += 1 : loss += 1)
    Sleep(1000)

    if ((A_TickCount - webhookSendTime) >= GetWebhookDelay()) { ; Custom cooldown
        try {
            SendWebhookWithTime(isWin, stageLength)
        } catch {
            AddToLog("Error: Unable to send webhook.")
        }
    } else {
        UpdateStreak(isWin) ; Needed for webhook
    }
    ; ─── End-of-Stage Handling Loop ───
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
                return CheckLobby()
            } else {
                AddToLog("Returning to lobby to start next map: " challengeMapList[challengeMapIndex])
                ClickReturnToLobby()
                return CheckLobby()
            }
        } else {
            ClickNextLevel()
            return RestartStage()
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
            return CheckLobby()
        }
    }

    ; ─── Mode Handling ───
    if (ModeDropdown.Text = "Story") {
        HandleStoryMode()
    } else {
        HandleDefaultMode()
    }
}

HandleStoryMode() {
    global lastResult

    if (lastResult "win" && NextLevelBox.Value) {
        ClickNextLevel()
    } else {
        ClickReplay()
    }
    return RestartStage()
}

HandleDefaultMode() {
    if (ReturnLobbyBox.Value) {
        ClickReturnToLobby()
        return CheckLobby()
    } else {
        ClickReplay()
    }
    return RestartStage()
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
    if (FindText(&X, &Y, 343, 467, 461, 496, 0.05, 0.20, Back)) {
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
    Sleep(500)

    FixClick(476, 466) ; Click Legend Stages
    Sleep(500)

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
    FixClick(485, 410)  ;Create
    Sleep (1500)
    FixClick(400, 475) ;Start
    Sleep (1200)
}

CreateChallenge() {
    FixClick(284, 259) ; Click Create Challenge
    Sleep(1500)
    FixClick(400, 475) ;Start
    Sleep (1000)
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
    if (ok := FindText(&X, &Y, 123, 50, 156, 79, 0, 0, OpenChat)) {
        AddToLog "Closing Chat"
        FixClick(138, 30) ;close chat
    }
}

BasicSetup() {
    CloseChat()
    Sleep 300
}

DetectMap() {
    AddToLog("Trying to determine map...")
    startTime := A_TickCount
    
    Loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (ok := FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
                AddToLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddToLog("Could not detect map after 5 minutes - proceeding without movement")
            return "No Map Found"
        }

        ; Check for vote screen
        if (ok := FindText(&X, &Y, 355, 168, 450, 196, 0, 0, VoteStart) or PixelGetColor(492, 47) = 0x5ED800) {
            AddToLog("No Map Found or Movement Unnecessary")
            return "No Map Found"
        }

        mapPatterns := Map(
            "Voocha Village", VoochaVillage,
            "Green Planet", GreenPlanet,
            "Demon Forest", DemonForest,
            "Leaf Village", LeafVillage,
            "Z City", ZCity,

            "Cursed Town", CursedTown,
            "Egg Island", EggIsland
        )

        for mapName, pattern in mapPatterns {
            if (ok := FindText(&X, &Y, 11, 159, 450, 285, 0, 0, pattern)) {
                AddToLog("Detected map: " mapName)
                return mapName
            }
        }
        Sleep 1000
        Reconnect()
    }
}
    
RestartStage() {
    global currentMap

    FindText

    if (currentMap = "") {
        currentMap := DetectMap()
    } else {
        AddToLog("Current Map: " currentMap)
    }

    ; Wait for loading
    CheckLoaded()

    ; Wait for game to actually start
    StartedGame()

    ;Summon Units
    SummonUnits()
    
    ; Monitor stage progress
    MonitorEndScreen()
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
            if (ok := FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
                AddToLog("Reconnected Successfully!")
                return StartSelectedMode()
            } else {
                Reconnect() 
            }
        }
    }
}

RejoinPrivateServer() {   
    AddToLog("Attempting To Reconnect To Private Server...")

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
            Sleep(1000)
        }

        if (ok := FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
            AddToLog("Reconnected Successfully!")
            return StartSelectedMode()
        }

        Reconnect()
    }
}


CheckForXp() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 118, 181, 219, 217, 0.05, 0.05, GameEnded)) {
        FixClick(560, 560)
        return true
    }
    return false
}

CheckLobby() {
    global currentMap
    loop {
        if (ok := FindText(&X, &Y, 47, 342, 83, 374, 0, 0, AreaText)) {
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

CheckLoaded() {
    startTime := A_TickCount
    timeout := 120 * 1000 ; Convert to milliseconds

    loop {
        Sleep(1000)

        if (ok := FindText(&X, &Y, 609, 463, 723, 495, 0.05, 0.20, UnitManagerBack)) {
            AddToLog("Unit Manager is open - closing it")
            SendInput("{T}")
            FixClick(665, 450)
            Sleep(1000)
        }
        
        if (ok := FindText(&X, &Y, 355, 168, 450, 196, 0.05, 0.20, VoteStart) or PixelGetColor(381, 47) = 0x5ED800) {
            AddToLog("Successfully Loaded In")
            Sleep(1000)
            break
        }

        ; Failsafe check
        if (A_TickCount - startTime > timeout) {
            AddToLog("Failed to load within 2 minutes. Rejoining the game.")
            return RejoinPrivateServer()
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(1000)
        if (ok := FindText(&X, &Y, 355, 168, 450, 196, 0, 0, VoteStart)) {
            FixClick(401, 149)
            continue  ; Keep waiting if vote screen is still there
        }
        
        ; If we don't see vote screen anymore the game has started
        AddToLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

StartSelectedMode() {
    global inChallengeMode, firstStartup, challengeStartTime

    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)

    if (ChallengeBox.Value && firstStartup) {
        AddToLog("Auto Ranger Stage enabled - starting with Ranger Stage")
        inChallengeMode := true
        firstStartup := false
        challengeStartTime := A_TickCount  ; Set initial challenge time
        LegendMode()
        return
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
    upgradePoints := UnitUpgradePoints()
    pointIndex := 1
    upgradeUnits := ShouldUpgradeUnits.Value
    
    ; Collect enabled slots
    enabledSlots := []
    for slotNum in GetPlacementOrder() {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            enabledSlots.Push(slotNum)
        }
    }

    if (enabledSlots.Length = 0) {
        if (debugMessages) {
            AddToLog("No units enabled - monitoring stage")
        }
        return
    }

    if (AutoPlay.Value && !upgradeUnits) {
        AddToLog("Autoplay is enabled and auto upgrade is disabled - monitoring stage")
        return
    }

    if (upgradeUnits && upgradePoints.Length > 0) {
        if (ok := !FindText(&X, &Y, 609, 463, 723, 495, 0.05, 0.20, UnitManagerBack)) {
            AddToLog("Unit Manager isn't open - trying to open it")
            Loop {
                ; Check if the Unit Manager is still open
                if (ok := !FindText(&X, &Y, 609, 463, 723, 495, 0.05, 0.20, UnitManagerBack)) {
                    SendInput("{T}")
                    Sleep(1000)  ; Wait for the Unit Manager to open
                } else {
                    AddToLog("Unit Manager is open")
                    break  ; Exit the loop once the Unit Manager is open
                }
            }
        }
    }
    
    while true {
        for slotIndex, slotNum in enabledSlots {
            point := (pointIndex <= upgradePoints.Length) ? upgradePoints[pointIndex] : ""

            if (upgradeUnits && point) {
                loop UpgradeClicks.Value {
                    FixClick(point.x, point.y)
                    Sleep 50
                }
            }
             else if (AutoPlay.Value) {
                return MonitorEndScreen() ; If not upgrading, just monitor the stage
            }
            
            if (!AutoPlay.Value) {
                SendInput("{" slotNum "}")
                Sleep 50
            }

            if CheckForXp() {
                return MonitorEndScreen()
            }

            Reconnect()
            Sleep(500) ; Prevent spamming

            ; Move to the next upgrade point, loop back if at the end
            pointIndex++
            if (pointIndex > upgradePoints.Length) {
                pointIndex := 1
            }
        }
    }
}

UseUnitPoints() {
    ; Define all possible points
    allPoints := [
        { x: 280, y: 530 },
        { x: 330, y: 530 },
        { x: 375, y: 530 },
        { x: 425, y: 530 },
        { x: 470, y: 530 },
        { x: 520, y: 530 }
    ]

    points := []
    orderedSlots := GetPlacementOrder()

    ; Track only enabled slots in placement order
    enabledSlots := []
    for slotNum in orderedSlots {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        if (enabled) {
            enabledSlots.Push(slotNum)
        }
    }

    ; Assign placement points based on order
    for i, slotNum in enabledSlots {
        if (i > allPoints.Length)
            break
        points.Push({ slot: slotNum, x: allPoints[i].x, y: allPoints[i].y })
    }

    return points
}


UnitUpgradePoints() {
    ; Define all possible points for the slots
    allPoints := [
        { x: 715, y: 190 },
        { x: 715, y: 275 },
        { x: 715, y: 350 },

        { x: 715, y: 190 },
        { x: 715, y: 275 },
        { x: 715, y: 350 }
    ]

    points := []
    enabledSlots := []

    for slotNum in GetPlacementOrder() {
        enabled := "enabled" slotNum
        enabled := %enabled%
        enabled := enabled.Value
        upgradeEnabled := "upgradeEnabled" slotNum
        upgradeEnabled := %upgradeEnabled%
        upgradeEnabled := upgradeEnabled.Value
        if (enabled && upgradeEnabled) {
            enabledSlots.Push(slotNum)
        }
    }

    for slotNum in enabledSlots {
        points.Push(allPoints[slotNum])
    }

    return points
}

GetWebhookDelay() {
    speeds := [0, 60000, 180000, 300000, 600000]  ; Array of sleep values
    speedIndex := WebhookSleepTimer.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}