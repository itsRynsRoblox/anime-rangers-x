#Requires AutoHotkey v2.0
#Include Image.ahk

global macroStartTime := A_TickCount
global stageStartTime := A_TickCount

global completedChallengeMaps := Map()
global currentMap := ""

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

CheckForTerminationConditions() {
    if (CheckForXp() || CheckForReturnToLobby()) {
        AddToLog("Stage ended during upgrades, proceeding to results")
        return MonitorStage()
    }
    Reconnect()
    if (CheckForLobbyText()) {
        return CheckLobby()
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
    while !(ok := FindText(&X, &Y, 12, 241, 148, 275, 0.05, 0.20, CreateRoom)) {
        AddToLog("Looking for Create Room button...")
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }

    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

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
    global challengeMapIndex, challengeMapList

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
        return CheckLobby()
    }

    currentLegendMap := challengeMapList[challengeMapIndex]
    currentLegendAct := "Act 1"
    
    ; Execute the movement pattern
    AddToLog("Moving to position for " currentLegendMap)
    StoryMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 12, 241, 148, 275, 0.05, 0.20, CreateRoom)) {
        if (debugMessages) {
            AddToLog("Debug: Looking for create room text...")
        }
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        StoryMovement()
    }

    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

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
    RaidMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        RaidMovement()
    }
    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)

    PlayHere()
    RestartStage()
}

InfinityCastleMode() {
    global InfinityCastleDropdown
    
    ; Get current difficulty
    currentDifficulty := InfinityCastleDropdown.Text
    
    ; Execute the movement pattern
    AddToLog("Moving to position for Infinity Castle")
    InfCastleMovement()
    
    ; Start stage
    while !(ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        Reconnect() ; Added Disconnect Check
        InfCastleMovement()
    }
    AddToLog("Starting Infinity Castle - " currentDifficulty)

    ; Select difficulty with direct clicks
    if (currentDifficulty = "Normal") {
        FixClick(418, 375)  ; Click Easy Mode
    } else {
        FixClick(485, 375)  ; Click Hard Mode
    }
    
    ;Start Inf Castle
    if (ok := FindText(&X, &Y, 325, 520, 489, 587, 0, 0, ModeCancel)) {
        ClickUntilGone(0, 0, 325, 520, 489, 587, ModeCancel, -10, -120)
    }

    RestartStage()
}

CheckForReturnToLobby() {
    if (ok := FindText(&X, &Y, 80, 85, 739, 224, 0, 0, LobbyText)) {
        return true
    }
    return false
}

MonitorEndScreen() {
    global StoryDropdown, StoryActDropdown
    global challengeStartTime, inChallengeMode, challengeStageCount, challengeMapIndex, challengeMapList

    Loop {
        Sleep(3000)  

        CloseChat()

        ; Now handle each mode
        if (ok := FindText(&X, &Y, 135, 399, 539, 456, 0, 0, LobbyText)) {
            AddToLog("Found Lobby Text - Current Mode: " (inChallengeMode ? "Ranger Stages" : ModeDropdown.Text))
            Sleep(2000)

            ; Logic to track challenge progress
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
                        challengeStartTime := A_TickCount  ; Reset timer for next ranger stage trigger
                        challengeMapIndex := 1  ; Reset map index for next session
                        ClickReturnToLobby()
                        return CheckLobby()
                    } else {
                        AddToLog("Returning to lobby to start next map: " challengeMapList[challengeMapIndex])
                        ClickReturnToLobby()
                        return CheckLobby()
                    }
                } else {
                    ; Proceed to the next challenge stage
                    ClickNextLevel()
                    return RestartStage()
                }
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && ChallengeBox.Value) {
                timeElapsed := A_TickCount - challengeStartTime
                if (timeElapsed >= 1800000) {
                    AddToLog("30 minutes has passed - switching to Ranger Stages")
                    inChallengeMode := true
                    challengeStartTime := A_TickCount
                    challengeStageCount := 0  ; Reset stage count for new ranger stage session
                    ClickReturnToLobby()
                    return CheckLobby()
                }
            }

            if (mode = "Story") {
                AddToLog("Handling Story mode end")
                if (NextLevelBox.Value && lastResult = "win") {
                    AddToLog("Next level")
                    ClickNextLevel()
                } else {
                    AddToLog("Replay level")
                    ClickReplay()
                }
                return RestartStage()
            }
            else {
                AddToLog("Handling end case")
                AddToLog("Replaying")
                ClickReplay()
                return RestartStage()
            }
        }
        Reconnect()
    }
}


MonitorStage() {

    CloseChat() ; Close chat if open

    while !CheckForXp() {
        ClickThroughDrops()
        Reconnect()
        Sleep(1000)
    }

    if (CheckForXp()) {
        return HandleStageEnd()
    }
}

HandleStageEnd() {
    global Wins, loss, stageStartTime

    isWin := false

    stageEndTime := A_TickCount
    stageLength := FormatStageTime(stageEndTime - stageStartTime)

    if (ok := FindText(&X, &Y, 377, 228, 536, 276, 0.05, 0.80, DefeatText)) {
        isWin := false
    }

    if (ok := FindText(&X, &Y, 397, 222, 538, 273, 0.05, 0.80, VictoryText)) {
        isWin := true
    }

    if isWin {
        AddToLog("Victory detected - Stage Length: " stageLength)
        Wins += 1
    } else {
        AddToLog("Defeat detected - Stage Length: " stageLength)
        loss += 1
    }
    SendWebhookWithTime(isWin, stageLength)
    Sleep (500)
    return MonitorEndScreen() 
}

StoryMovement() {
    FixClick(65, 300)
    Sleep (1000)
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
    FixClick(357, 225) ; Teleport to Challenges
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
}

RaidMovement() {
    FixClick(765, 475) ; Click Area
    Sleep(300)
    FixClick(495, 410)
    Sleep(500)
    SendInput ("{a down}")
    Sleep(400)
    SendInput ("{a up}")
    Sleep(500)
    SendInput ("{w down}")
    Sleep(5000)
    SendInput ("{w up}")
}

InfCastleMovement() {
    FixClick(765, 475)
    Sleep (300)
    FixClick(370, 330)
    Sleep (500)
    SendInput ("{w down}")
    Sleep (500)
    SendInput ("{w up}")
    Sleep (500)
    SendInput ("{a down}")
    sleep (4000)
    SendInput ("{a up}")
    Sleep (500)
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
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

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
    
    ; Closes Player leaderboard
    FixClick(640, 70)
    Sleep(500)

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

TpLobby() {
    FixClick(26, 570) ;click settings
    Sleep 300
    FixClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 250
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    FixClick(525, 415)
    Sleep 300
    return CheckLobby()
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
            if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
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

IsCorrectMap(mapName) {
    if (ModeDropdown.Text = "Story") {
        if (mapName = "No Map Found") {
            return false
        }
        return mapName = StoryDropdown.Text
    } else if (ModeDropdown.Text = "Legend") {
        return mapName = LegendDropdown.Text
    } else if (ModeDropdown.Text = "Raid") {
        return RaidDropdown.Text
    } else {
        return true
    }
}

HandleMapMovement(MapName) {
    AddToLog("Executing Movement for: " MapName)
    
    switch MapName {
  
    }
}
    
RestartStage() {
    global currentMap

    if (currentMap = "") {
        currentMap := DetectMap()
    } else {
        AddToLog("Current Map: " currentMap)
    }

    ; Wait for loading
    CheckLoaded()
    
    if (currentMap != "No Map Found") {
        HandleMapMovement(currentMap)
    }

    ; Wait for game to actually start
    StartedGame()
    
    ; Monitor stage progress
    MonitorStage()
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
            if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
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
        Run("roblox://placeID=72829404259339")  ; Public server if no PS file or empty
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

        if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
            AddToLog("Reconnected Successfully!")
            return StartSelectedMode()
        }

        Reconnect()
    }
}


CheckForXp() {
    ; Check for lobby text
    if (ok := FindText(&X, &Y, 118, 181, 219, 217, 0, 0, GameEnded)) {
        FixClick(560, 560)
        return true
    }
    return false
}

CheckLobby() {
    global currentMap
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
            break
        }
        if (CheckForEndGameScreens()) {
            return MonitorStage()
        }
        Reconnect()
    }
    Sleep(SleepTime())
    AddToLog("Returned to lobby, restarting selected mode")
    currentMap := ""
    return StartSelectedMode()
}

CheckForEndGameScreens() {
    if (CheckForXp() || CheckForReturnToLobby()) {
        AddToLog("Detected end game screen when should have already returned to lobby")
        CloseChat()
        return true
    }
}

CheckForLobbyText() {
    if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
        return true
    }
    return false
}

CheckForLobby() {
    loop {
        Sleep 1000
        if (ok := FindText(&X, &Y, 50, 317, 81, 350, 0, 0, AreaText)) {
            break
        }
        Reconnect()
    }
    AddToLog("Returned to lobby.")
    return true
}

CheckLoaded() {
    startTime := A_TickCount
    timeout := 120 * 1000 ; Convert to milliseconds

    loop {
        Sleep(1000)
        
        ; Check for vote screen
        if (ok := FindText(&X, &Y, 355, 168, 450, 196, 0, 0, VoteStart) or PixelGetColor(492, 47) = 0x5ED800) {
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

ClickUntilGone(x, y, searchX1, searchY1, searchX2, searchY2, textToFind, offsetX:=0, offsetY:=0, textToFind2:="") {
    waitTime := A_TickCount ; Start timer
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {
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
    while (ok := FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind) || 
           textToFind2 && FindText(&X, &Y, searchX1, searchY1, searchX2, searchY2, 0, 0, textToFind2)) {

        if (offsetX != 0 || offsetY != 0) {
            FixClick(X + offsetX, Y + offsetY, "Right")  
        } else {
            FixClick(x, y, "Right") 
        }
        Sleep(1000)
    }
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

ClickReplay() {
    xCoord := (ModeDropdown.Text != "Story" || StoryDropdown.Text = "Z City") ? -120 : -250
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, xCoord, -35)
}

ClickNextLevel() {
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, -120, -35)
}

ClickReturnToLobby() {
    ClickUntilGone(0, 0, 135, 399, 539, 456, LobbyText, 0, -35)
}

ClickStartStory() {
    ClickUntilGone(0, 0, 320, 468, 486, 521, StartStoryButton, 0, -35)
}

ClickThroughDrops() {
    if (debugMessages) {
        AddToLog("Clicking through item drops...")
    }
    Loop 5 {
        FixClick(400, 495)
        Sleep(500)
    }
}