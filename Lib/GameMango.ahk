#Requires AutoHotkey v2.0
#Include Image.ahk

global macroStartTime := A_TickCount
global stageStartTime := A_TickCount
global ReturnToLobbyStartTime := A_TickCount

global inBossAttackMode := false
global inChallengeMode := false
global currentMap := ""
global checkForUnitManager := true
global lastHourCheck := A_Hour
global startingMode := true
global isUpgrading := true
global autoAbilityClicking := false
global inStage := false

global CidMapPattern1 := "|<>**50$273.000000000000000zU0000000000000000000zU0000000000000000000000CC0000000000000000000DC00000000Ts00000000000010M0000000000000007zw10M000000073U000000000000830000000000000007k3s831z000000UA00000000000010M000000000000001k03l0MQQ0000041U00000000000083000000000000000s0078320k00000U400000000000010M00000000000000C000N0ME60000040U000000000000830000000000000030001c320k00000U400000000000010M00000000000000k000BUsE60000040U000TXw7s3s1w8301zy03zw0Dzk00M0Dw37wS0zXw07sU4000TzttlUvkMt0M0w0w1s1w7U7k0307Uslzrk3ysk1Xo0U0070A3M6A661c30C01kQ01lk0700E1k3w83U00Q3086U4001U00+0lUMU50M70073006A00M060Q0010Q0030M30Q0U00M001E2M1A0c30k00Mk00H00100k300083U00M1UE3U4006000+0P0BU50MA001a006M00M060k0010Q0030660Q0U01U001E3E1c1c330004U00m00300U600083U00Q0kk2U400A000/0C070B0MM000o1yAE7sk040U0010Q003U3A0o0U01000181k0s383207U6UCz20vw00U400083k00q0NU6U400M0w09U4060N08k3a0o0zUE3y0040U0010Dk7yk1s1Y0U030Dk1A0U0E28360Tk6U0D200w00U60008320k3070AU400E3308U0000l08U3w0q00AM00k060k00108E60A0k340U020MM16000068140006k00n00300k30008120k1U20MU400E2308E0001V08U000X002A008060M00108E60600240U020MM130000A814000AA00Mk01U0E1k1w8120k0k00kU400M1a08M0001108U0070s033U0A03070sl08E20300440U0307U1100k0M81q0TzkTs09zU0U080Dw38120Q0801UU7zz80008A0602107k3ry6Ds1MzU401U040N08E1w1U084000RU0010U1k0k80C07kMUT0+1w0U04000181200U6030U000g000860D06100s001A001k00400k000908E040k0M40004k0010E180U805000B000Q001U03000181300U3060U000X000830N0A1U0g001c002U00800A000908804080k40004A0010M2A10404k00BU00q003000s007811U0U1040U000Uk1U810kUM0k0X001600AM00k001k01l0M6040M1U6000A3Uy70CA7603UAC00sS071s0Q0007U1sA60S1U2080Tzzz07wTk0z0TU07z0Tzw0zzU3zy00007zw0zU0zs0k300000000000000000000Ds00000000000000000000040E0000000000000000000000000000000000000000000U60000000000000000000000000000000000000000000A0U0000000000000000000000000000000000000000001040000000000000000000000000000000000000000000M1U0000000000000000000000000000000000000000002080000000000000000000000000000000000000000000E3000000000000000000000000000000000000000000030E0000000000000000000000000000000000000000000A600000000000000000000000000000000000000000000tU04"
global CidMapPattern2 := "|<>**50$273.000000000000000zU0000000000000000000zU0000000000000000000000CC0000000000000000000DC00000000Ts00000000000010M0000000000000007zw10M000000073U000000000000830000000000000007k3s831z000000UA00000000000010M000000000000001k03l0MQQ0000041U00000000000083000000000000000s0078320k00000U400000000000010M00000000000000C000N0ME60000040U000000000000830000000000000030001c320k00000U400000000000010M00000000000000k000BUsE60000040U000TXw7s3s1w8301zy03zw0Dzk00M0Dw37wS0zXw07sU4000TzttlUvkMt0M0w0w1s1w7U7k0307Uslzrk3ysk1Xo0U0070A3M6A661c30C01kQ01lk0700E1k3w83U00Q3086U4001U00+0lUMU50M70073006A00M060Q0010Q0030M30Q0U00M001E2M1A0c30k00Mk00H00100k300083U00M1UE3U4006000+0P0BU50MA001a006M00M060k0010Q0030660Q0U01U001E3E1c1c330004U00m00300U600083U00Q0kk2U400A000/0C070B0MM000o1yAE7sk040U0010Q003U3A0o0U01000181k0s383207U6UCz20vw00U400083k00q0NU6U400M0w09U4060N08k3a0o0zUE3y0040U0010Dk7yk1s1Y0U030Dk1A0U0E28360Tk6U0D200w00U60008320k3070AU400E3308U0000l08U3w0q00AM00k060k00108E60A0k340U020MM16000068140006k00n00300k30008120k1U20MU400E2308E0001V08U000X002A008060M00108E60600240U020MM130000A814000AA00Mk01U0E1k1w8120k0k00kU400M1a08M0001108U0070s033U0A03070sl08E20300440U0307U1100k0M81q0TzkTs09zU0U080Dw38120Q0801UU7zz80008A0602107k3ry6Ds1MzU401U040N08E1w1U084000RU0010U1k0k80C07kMUT0+1w0U04000181200U6030U000g000860D06100s001A001k00400k000908E040k0M40004k0010E180U805000B000Q001U03000181300U3060U000X000830N0A1U0g001c002U00800A000908804080k40004A0010M2A10404k00BU00q003000s007811U0U1040U000Uk1U810kUM0k0X001600AM00k001k01l0M6040M1U6000A3Uy70CA7603UAC00sS071s0Q0007U1sA60S1U2080Tzzz07wTk0z0TU07z0Tzw0zzU3zy00007zw0zU0zs0k300000000000000000000Ds00000000000000000000040E0000000000000000000000000000000000000000000U60000000000000000000000000000000000000000000A0U0000000000000000000000000000000000000000001040000000000000000000000000000000000000000000M1U0000000000000000000000000000000000000000002080000000000000000000000000000000000000000000E3000000000000000000000000000000000000000000030E0000000000000000000000000000000000000000000A600000000000000000000000000000000000000000000tU04"

global lastVoteCheck := 0
global voteCheckCooldown := 1500
global justHitBossAttackCooldown := false
global currentRangerSkipIndex := 1

global LawlessCityPattern := "|<>**50$273.000000000000001lk0000000000000000001tk00000003z0000000000000830000000000000000zzU8300000000sQ00000000000010M000000000000000y0T10MDs0000041U00000000000083000000000000000C00S833XU00000UA00000000000010M000000000000007000t0ME60000040U00000000000083000000000000001k0038320k00000U400000000000010M00000000000000M000B0ME60000040U000000000000830000000000000060001g720k00000U40003wTUz0T0DV0M0Dzk0TzU1zy00301zUMzXk7wTU0z40U003zzDCA7S378307U7UD0DUw0y00M0w76Dyy0Tr60ASU4000s1UP0lUkkB0M1k0C3U0CC00s020C0TV0Q003UM10o0U00A001E6A340c30s00sM00lU0300k3U0083U00M30M3U4003000+0H09U50M60036002M008060M0010Q0030A20Q0U00k001E3M1g0c31U00Ak00n00300k600083U00M0kk3U400A000+0O0B0B0MM000Y006E00M040k0010Q003U660I0U01U001M1k0s1c330006UDlW0z600U400083U00Q0NU6U400800090C070N0ME0w0o1rsE7TU040U0010S006k3A0o0U0307U1A0U0k38160Qk6U7w20Tk00U400081y0zq0D0AU400M1y09U4020F0Mk3y0o01sE07U040k0010ME60M0s1Y0U020MM14000068140TU6k01X00600k60008120k1U60MU400E3308k0000l08U000q006M00M060M00108E60A0E340U020EM120000A8140004M00FU0100k30008120k0k00EU400E3308M0001V08U001VU03600A020C0DV08E60600640U030Ak1300008814000s700MQ01U0M0s768120E0M00UU400M0w088060310Ck3zy3z01Dw040101zUN08E3U100A40zzt00011U0k0E80y0Szklz0/7w0U0A00U38120DUA010U003g000840C06101k0y343s1EDU400U000908E040k0M40005U0010k1s0k8070009U00C000U06000181200U6030U000a000820904100c001c003U00A00M000908M040M0k40004M0010M381UA05U00B000I001001U00181100U1060U000VU00830FU80U0a001g006k00M007000t08A04080U4000460A1086430604M008k01X006000C00C830k0U30A0k001UQ7ks1lUsk0Q1Vk073k0sD03U000w0D1Uk3kA0E103zzzs0zXy07s3w00zs3zzU7zw0Tzk0000zzU7w07z060M00000000000000000001z0000000000000000000000U2000000000000000000000000000000000000000000040k0000000000000000000000000000000000000000001U4000000000000000000000000000000000000000000080U00000000000000000000000000000000000000000030A0000000000000000000000000000000000000000000E1000000000000000000000000000000000000000000020M0000000000000000000000000000000000000000000M200000000000000000000000000000000000000000001Uk00000000000000000000000000000000000000000007A00U"

global NewCustomMapPattern := "|<>**50$274.000000000000000Tk0000000000000000000Tk00000000000000000000003XU0000000000000000M03nU00000003z0000000000000830000000000000000zz08300000000QC0000000000000UA000000000000000D0DUUA7w0000010M00000000000020k000000000000003U0760kss0000041U00000000000083000000000000000s007M320k00000E20000000000000UA000000000000007000AUAM30000010800000000000020k00000000000000k000O0lUA0000040U000000000000830000000000000060001g660k00000E20000000000000UA00000000000000M0006TsM30000010800000000000020k000000000000030000k01UA0C00E40U000TXw7s3s1w8301zy03zw0Dzk00M0Dw33wS0zXw07sE2000DzwwskRsAQUA0S0S0w0y1k3s01U3kQMzvs1zQM0lt08001k30q1X1VUO0k3U0Q700QQ01k040Q0z20s0070k21Y0U00A001E6A340c30s00sM00lU0300k300083U00M30M3E2001U00509U4k2UA3001X001A004030A001UC001U610B0800A000I0q0P0+0kM003A00Ak00k0A1U0060s0060AA0o0U01U001E3E1c1c330004U00m00300U6000M3U00Q0kk3E20060005U703U6UAA000O0z683wM020E001UC001k1a0N0800E000G0Q0C0m0kU1s1c3jkUCz008100060w00DU6M1Y0U0307U1A0U0k38160Qk6U7w20Tk00U4000M1y0zq0D0AE200A0z04k20108UAM1r0O00w803k020M001UAs3wA0Q0l0800U660F00001W0F07s1g00Mk01U0A1U0060FUA0M1U640U020MM16000068140006E00l00300k3000M160k1U20ME200811U480000kU4E000FU016004010A001U4M30300110800U660Ek000320F00033006A00M040M0T60FUA0A00A40U030Ak1300008814000s700MQ01U0M0s76M160E0M00UE200A0S0440301UU7M1zz1zU0by0200U0zk9U4M1w1U0610DzyE000EM0A0420DU7jwATk2lz08030080q0EU3s300M4000RU0010U1k0k80C07kMUT0+1w0U04000181200U6030E000K0004307U30U0Q000a000s00200M0004U48030M0A10001A000E40G08201E002E007000M00k000G0Ek0A0k1U40004M0010M381UA05U00B000I001001U00181100k3060E000Ek0041U8k40E0H000q003M00A003U00QU46030A0E100011U30E21V0k1U16002A00Mk01U003U0320kA0A0k306000A3Uy70CA7603UAC00sS071s0Q0003U1sA60S1U2080DzzzU3yDs0TUDk03zUDzy0Tzk1zz00003zy0Tk0Tw0M1U00000000000000000003y0000000000000y00000001040000000000000000000000000000000000000000000kE000000000000000000000000000000000000000000031000000000000U"

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
    StartContent(StoryDropdown.Text, StoryActDropdown.Text, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
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

BossAttack() {
    global startingMode, inBossAttackMode, challengeStartTime, justHitBossAttackCooldown, BossAttackStartTime
    
    BossAttackCameraChange()
    BossAttackMovement()
    Sleep(1000) 

    
    while !(ok := GetFindText().FindText(&X, &Y, 210, 147, 412, 220, 0, 0, PlayBoss)) {
        Reconnect() ; Added Disconnect Check
        FixClick(398, 322) ; Click close
        Sleep (200)
        FixClick(559, 167)
        BossAttackCameraChange()
        BossAttackMovement()
    }
    
    StartBossAttack()

    if (GetFindText().FindText(&X, &Y, 294, 300, 516, 411, 0, 0, Close)) {
        AddToLog("Boss Attack on Cooldown...")
        FixClick(399, 318)
        Sleep (200)
        FixClick(558, 164)
        Sleep(1000)
        inBossAttackMode := false
        justHitBossAttackCooldown := true
        BossAttackStartTime := A_TickCount
        BossAttackMapStegeCount := 0
        inStage := false
        if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
            autoAbilityClicking := false
            SetTimer(AutoAbility_ClickLoop, 0)
            Sleep(200)
        }
        startingMode := true
        CheckLobby()
        return
    }

    startingMode := false
    justHitBossAttackCooldown := false
}

Portal() {
    global startingMode

    currentPortalMap := PortalDropdown.Text

    PortalMovement()
    AddToLog("Starting Portal for " currentPortalMap)
    Sleep(1000)

    while !(ok := GetFindText().FindText(&X, &Y, 77, 196, 240, 294, 0, 0, PortalText)) {
        RemovePortalName() ; Remove Portal Name
        Reconnect() ; Added Disconnect Check
        FixClick(80, 325) ; Click Leave
        Sleep(1000)
        PortalMovement()
    }

    StartPortal()
    startingMode := false
}

ClickCidMap()
{
    t1 := A_TickCount, Text := X := Y := ""
    Text := "|<>**50$273.000000000000000zU0000000000000000000zU0000000000000000000000CC0000000000000000000DC00000000Ts00000000000010M0000000000000007zw10M000000073U000000000000830000000000000007k3s831z000000UA00000000000010M000000000000001k03l0MQQ0000041U00000000000083000000000000000s0078320k00000U400000000000010M00000000000000C000N0ME60000040U000000000000830000000000000030001c320k00000U400000000000010M00000000000000k000BUsE60000040U000TXw7s3s1w8301zy03zw0Dzk00M0Dw37wS0zXw07sU4000TzttlUvkMt0M0w0w1s1w7U7k0307Uslzrk3ysk1Xo0U0070A3M6A661c30C01kQ01lk0700E1k3w83U00Q3086U4001U00+0lUMU50M70073006A00M060Q0010Q0030M30Q0U00M001E2M1A0c30k00Mk00H00100k300083U00M1UE3U4006000+0P0BU50MA001a006M00M060k0010Q0030660Q0U01U001E3E1c1c330004U00m00300U600083U00Q0kk2U400A000/0C070B0MM000o1yAE7sk040U0010Q003U3A0o0U01000181k0s383207U6UCz20vw00U400083k00q0NU6U400M0w09U4060N08k3a0o0zUE3y0040U0010Dk7yk1s1Y0U030Dk1A0U0E28360Tk6U0D200w00U60008320k3070AU400E3308U0000l08U3w0q00AM00k060k00108E60A0k340U020MM16000068140006k00n00300k30008120k1U20MU400E2308E0001V08U000X002A008060M00108E60600240U020MM130000A814000AA00Mk01U0E1k1w8120k0k00kU400M1a08M0001108U0070s033U0A03070sl08E20300440U0307U1100k0M81q0TzkTs09zU0U080Dw38120Q0801UU7zz80008A0602107k3ry6Ds1MzU401U040N08E1w1U084000RU0010U1k0k80C07kMUT0+1w0U04000181200U6030U000g000860D06100s001A001k00400k000908E040k0M40004k0010E180U805000B000Q001U03000181300U3060U000X000830N0A1U0g001c002U00800A000908804080k40004A0010M2A10404k00BU00q003000s007811U0U1040U000Uk1U810kUM0k0X001600AM00k001k01l0M6040M1U6000A3Uy70CA7603UAC00sS071s0Q0007U1sA60S1U2080Tzzz07wTk0z0TU07z0Tzw0zzU3zy00007zw0zU0zs0k300000000000000000000Ds00000000000000000000040E0000000000000000000000000000000000000000000U60000000000000000000000000000000000000000000A0U0000000000000000000000000000000000000000001040000000000000000000000000000000000000000000M1U0000000000000000000000000000000000000000002080000000000000000000000000000000000000000000E3000000000000000000000000000000000000000000030E0000000000000000000000000000000000000000000A600000000000000000000000000000000000000000000tU04"
    if (ok := FindText(&X, &Y, 5, 37, 800, 600, 0, 0, Text))
    {
        FindText().Click(X, Y, "L")
        AddToLog("Clicked CID map at " X ", " Y)
    }
}

CidMode() {
    global startingMode, currentMap
    startingMode := false

    AddToLog("Trying to determine map...")
    startTime := A_TickCount
    found := false
    patterns := [
        {pattern: CidMapPattern1, x1: 155-15, y1: 187-15, x2: 155+15, y2: 187+15},
        {pattern: CidMapPattern2, x1: 154-15, y1: 231-15, x2: 154+15, y2: 231+15}
    ]
    while !found {
        ; First click with 0.5 second sleep
        FixClick(775, 234)
        Sleep(500)
        ; Second click with 0.2 second sleep
        FixClick(449, 367)
        Sleep(200)

        t1 := A_TickCount, Text := X := Y := ""
        ; Check for vote screen (like in DetectMap)
        if (GetFindText().FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart) 
            or PixelGetColor(492, 47) = 0x5ED800) {
            AddToLog("❌ No map was found before loading in (vote screen detected)")
            return
        }
        for i, p in patterns {
            Text := p.pattern
            if (ok := FindText(&X, &Y, p.x1, p.y1, p.x2, p.y2, 0, 0, Text)) {
                found := true
                break
            }
        }
        Try For i,v in ok
            if (i<=2)
                FindText().MouseTip(ok[i].x, ok[i].y)
        if (!found) {
            if (A_TickCount - startTime > 120000) { ; 2 minute timeout
                AddToLog("❌ Could not determine CID map after 2 minutes.")
                return
            }
            Sleep(1000)
            Reconnect()
        }
    }
    currentMap := "Lawless City"
    AddToLog("CID Mode map detected: " currentMap)
}


LegendMode() {
    global challengeMapIndex, challengeMapList, challengeStageCount, inChallengeMode, startingMode, BossAttackMapStegeCount, BossAttackMapIndex

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
        
        if (BossAttackBox.Value) { 
            AddToLog("All Ranger maps skipped. Switching to Boss Attack.")
            inBossAttackMode := true
            justHitBossAttackCooldown := false
            BossAttackMapStegeCount := 0       ; Reset Boss Attack stage counter
            BossAttackMapIndex := 1            ; Reset Boss Attack map index
            BossAttack()
            return
        } else { 
            AddToLog("All Ranger maps skipped. Boss Attack not selected. Resetting cycle timers.")
            challengeStartTime := A_TickCount ; รีเซ็ต shared timer เพราะวงจรจบที่นี่
            BossAttackStartTime := A_TickCount ; รีเซ็ต Boss Attack timer ด้วย
            CheckLobby()
            startingMode := true
            return
        }
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

RaidMode() {
    global RaidDropdown, RaidActDropdown, startingMode
    
    ; Get current map and act
    currentRaidMap := RaidDropdown.Text
    currentRaidAct := RaidActDropdown.Text
    
        ; Execute the movement pattern
    AddToLog("Moving to position for " currentRaidMap)
    RaidMovement()
    
    ; Start stage
    while !(ok := GetFindText().FindText(&X, &Y, 352, 101, 452, 120, 0.05, 0.20, RoomPods)) {
        FixClick(80, 325) ; Click Leave
        Reconnect() ; Added Disconnect Check
        RaidMovement()
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

    AddToLog("Starting " currentRaidMap " - " currentRaidAct)
    StartRaid(currentRaidMap, currentRaidAct)

    PlayHere()
}

MonitorEndScreen() {
    global inBossAttackMode, BossAttackMapActCount, BossAttackMapIndex, BossAttackStartTime, BossAttackMapStegeCount
    global Wins, loss, stageStartTime, lastResult, webhookSendTime, firstWebhook, justHitBossAttackCooldown, inStage

    isWin := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
    }

    lastClickTime := A_TickCount

    ; Wait for XP to appear or reconnect if necessary
    while !CheckForXp() {
        if ((A_TickCount - lastClickTime) >= 10000) {
            FixClick(400, 495)
            lastClickTime := A_TickCount
        }
        Sleep (150)
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

    ; Stop Auto Ability if running
    inStage := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
    }

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

    ; --- BossAttack Mode ---
    if (inBossAttackMode && !justHitBossAttackCooldown) {
        BossAttackMapStegeCount++
        AddToLog("Boss Attack stage completed. Count: " BossAttackMapStegeCount " / " BossAttackMapActCount[BossAttackMapIndex])
        if (BossAttackMapStegeCount >= BossAttackMapActCount[BossAttackMapIndex]) {
            AddToLog("Completed all " BossAttackMapActCount[BossAttackMapIndex] " Boss Attack runs.")
            BossAttackMapStegeCount := 0
            inBossAttackMode := false
            BossAttackStartTime := A_TickCount
            inStage := false
            if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
                autoAbilityClicking := false
                SetTimer(AutoAbility_ClickLoop, 0)
                SendInput("{T}")
                Sleep(200)
            }
            ClickReturnToLobby()
            CheckLobby()
            return
        } else {
            Sleep(500)
            if (CanReplay()) {
                AddToLog("Need " (BossAttackMapActCount[BossAttackMapIndex] - BossAttackMapStegeCount) " more stages")
                ClickNextLevel()
                return
            } else {
                AddToLog("Boss Attack ended early (no replay available). Returning to lobby and starting cooldown.")
                BossAttackMapStegeCount := 0
                inBossAttackMode := false
                BossAttackStartTime := A_TickCount
                inStage := false
                if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
                    autoAbilityClicking := false
                    SetTimer(AutoAbility_ClickLoop, 0)
                    SendInput("{T}")
                    Sleep(200)
                }
                ClickReturnToLobby()
                CheckLobby()
                StartSelectedMode()
                return
            }
        }
    }

    ; ─── Timed Mode Start (Separate Cooldowns) ───
    if (!inBossAttackMode) {
        bossAttackDue := BossAttackBox.Value && ((A_TickCount - BossAttackStartTime) >= GetBossAttackCDTime())
        if (bossAttackDue) {
            if (BossAttackBox.Value) {
                AddToLog(GetBossAttackCDTime() // 60000 " minutes have passed - switching to Boss Attack (independent).")
                inBossAttackMode := true
                BossAttackStartTime := A_TickCount
                BossAttackMapStegeCount := 0
                justHitBossAttackCooldown := false
                autoAbilityClicking := false
                ClickReturnToLobby()
                CheckLobby()
                return
            }
        }
    }

    ; --- Default Mode Handling ---
    inStage := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
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

    ; --- Ability State interrupt on win/loss ---
    inStage := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
        if (A_IsPaused) {
            TogglePause()
        }
    }
}


HandleStoryModeOld() {
    global lastResult

    if (NextLevelBox.Value && NextLevelBox.Visible) {
        ClickNextLevel()
    } else {
        ClickReplay2()
    }
    return RestartStage()
}

HandleDefaultModeOld() {
    if (ReturnLobbyBox.Visible && ReturnLobbyBox.Value && ModeDropdown.Text != "Cid") {
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

    if (ModeDropdown.Text = "Co-op" || ModeDropdown.Text = "Boss Rush") {
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

FormatTimeLeft(msRemaining) {
    minutes := Floor(msRemaining / 60000)
    seconds := Floor(Mod(msRemaining, 60000) / 1000)

    AddToLog("Returning to lobby in " . minutes . "m " . seconds . "s")
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

BossAttackCameraChange() {
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
        FixClick(518, 228)
        Sleep (300)
        FixClick(26, 330) ; Click Areas
        Sleep (300)
        FixClick(361, 226)  
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

BossAttackMovement() {
    Sleep (250)
    SendInput ("{a down}")
    Sleep (500) 
    SendInput ("{a up}")
    Sleep (250)
    SendInput ("{s down}")
    Sleep (1500)
    SendInput ("{s up}")
    Sleep (250)
    SendInput ("{a down}")
    Sleep (300)
    SendInput ("{a up}")

    loop 2 {
        SendInput ("{e}")
        Sleep (100)
    }
    Sleep (1000)
}

PortalMovement() {
    FixClick(26, 328) ; Click Areas
    Sleep(500)
    FixClick(437, 350)
    Sleep(500)
    FixClick(65, 293)
    Sleep(500)
    FixClick(296, 198)
    Sleep(500)
    SendInput(PortalDropdown.Text) ; Type the portal name
    Sleep(500)
    FixClick(267, 238)
    Sleep(500)
}

StartStoryOld(map, act, isRanger := false) {
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
    
    ; Click (468, 469) for Ranger mode right before clicking the map
    if (isRanger) {
        Sleep(2000)
        FixClick(468, 469)
        Sleep(200)
    }
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetMapData("StoryAct", act)
    
    if (isRanger) {
        Sleep(2000)
        ; No click here
    }

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

    ; Click the correct difficulty
    if (StoryDifficulty.Text = "Normal") {
        FixClick(522, 260)
    } else if (StoryDifficulty.Text = "Hard") {
        FixClick(569, 263)
    } else {
        ; Default to Nightmare
        FixClick(617, 264)
    }
    Sleep(1000)
    
    return true
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

StartRaid(map, act, isRanger := false) {
    AddToLog("Selecting map: " map " and act: " act)

    ; Get Story map 
    StoryMap := GetMapData("RaidMap", map)
    FixClick(541, 468) ; Click on Raid
    Sleep (200)
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
    
    ; Click (468, 469) for Ranger mode right before clicking the map
    if (isRanger) {
        Sleep(2000)
        FixClick(468, 469)
        Sleep(200)
    }
    ; Click on the map
    FixClick(StoryMap.x, StoryMap.y)
    Sleep(1000)
    
    ; Get act details
    StoryAct := GetMapData("RaidAct", act)
    
    if (isRanger) {
        Sleep(2000)
        ; No click here
    }
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
    global inChallengeMode, challengeMapIndex, challengeStageCount, challengeStartTime, startingMode, inBossAttackMode, BossAttackStartTime, BossAttackMapStegeCount, BossAttackMapIndex

    FixClick(485, 410)  ;Create
    if (inChallengeMode) {
        Sleep (500)
        if (CheckForCooldownMessage()) {
            AddToLog("Still on cooldown...")
            FixClick(580, 410) ; Exit Ranger Stages
            Sleep (2000)
            FixClick(70, 325) ; Exit 
            inChallengeMode := false
            ; challengeStartTime และ BossAttackStartTime จะถูกจัดการด้านล่าง
            challengeMapIndex := 1  ; Reset map index for next session
            challengeStageCount := 0  ; Reset stage count for new ranger stage session

            ; --- ADDED LOGIC ---
            if (BossAttackBox.Value) {
                AddToLog("Ranger Stages on cooldown. Switching to Boss Attack.")
                inBossAttackMode := true
                justHitBossAttackCooldown := false ; เพื่อให้ Boss Attack พยายามทำงาน
                ; BossAttackStartTime และ challengeStartTime ไม่รีเซ็ตที่นี่
                BossAttackMapStegeCount := 0
                BossAttackMapIndex := 1
            } else {
                BossAttackStartTime := A_TickCount ; รีเซ็ต Boss Attack timer ด้วย
             }

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

StartBossAttack() {
    inStage := true
    autoAbilityClicking := true
    FixClick(350, 352) ; Click Boss Attack
    Sleep(3000)
}

StartPortal() {
    FixClick(160, 349) ; Click Use Portal
    Sleep(1000)
    FixClick(115, 323) ; Start
    Sleep(2000)
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
    global lastHourCheck, NewCustomMapPattern

    startTime := A_TickCount
    AddToLog("Trying to determine map...")

    mapPatterns := Map(
        "Voocha Village", VoochaVillage,
        "Green Planet", GreenPlanet,
        "Demon Forest", DemonForest,
        "Leaf Village", LeafVillage,
        "Z City", ZCity,
        "Ghoul City", GhoulCity,
        "Night Colosseum", NightColosseum,
        "Cursed Town", CursedTown,
        "Lawless City", LawlessCityPattern,
        "New Custom Map", NewCustomMapPattern,
        "Battle Arena", BattleArena,
        "Bizzare Race", BizzareRace,
        "Steel Blitz Rush", SteelBlitzRush
    )

    Loop {
        if (waitForLoadingScreen = true) {
            if (A_TickCount - startTime > GetLoadingScreenWaitTime()) {
                AddToLog("❌ No map was found after waiting " GetLoadingWaitInSeconds() " seconds.")
                lastHourCheck := A_Hour
                return "No Map Found"
            }
        } else {
            ; Timeout after 10 minutes
            if (A_TickCount - startTime > 600000) {
                if (ok := GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)) {
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
            if (mapName = "New Custom Map") {
                if (ok := GetFindText().FindText(&X, &Y, 155-150000, 204-150000, 155+150000, 204+150000, 0, 0, pattern)) {
                    AddToLog("✅ Map detected: " mapName)
                    lastHourCheck := A_Hour
                    return mapName
                }
            } else {
                if (ok := GetFindText().FindText(&X, &Y, 11, 159, 450, 285, 0, 0, pattern)) {
                    AddToLog("✅ Map detected: " mapName)
                    lastHourCheck := A_Hour
                    return mapName
                }
            }
        }
        Sleep 1000
        Reconnect()
    }
}
    
RestartStage() {
    global currentMap, checkForUnitManager, lastHourCheck, inChallengeMode, startingMode, inBossAttackMode, ReturnToLobbyStartTime

    loop {

        if (startingMode) {
            StartSelectedMode()
            continue ; immediately restart loop with new mode
        }

        checkForUnitManager := true

        if (ModeDropdown.Text = "Challenge" && !inChallengeMode && !inBossAttackMode) {
            if (A_Hour != lastHourCheck) {
                currentMap := DetectMap(true)  ; Force re-detect the map
            } else {
                if (currentMap = "") {
                    currentMap := DetectMap(false)  ; Detect once if not already known
                }
            }
        } else if (ModeValidForMapDetection(ModeDropdown.Text)) {
            if (currentMap = "") {
                currentMap := DetectMap(false)  ; Normal detect
            } else {
                AddToLog("Current Map: " currentMap)
            }
        }

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

        ; ===== เพิ่มส่วนนี้ =====
        inStage := false
        if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
            autoAbilityClicking := false
            SetTimer(AutoAbility_ClickLoop, 0)
            SendInput("{T}")
            Sleep(200)
        }
        ; ========================
        
        ; Monitor stage progress
        MonitorEndScreen()

    }
}

Reconnect() {
    global justHitBossAttackCooldown
    justHitBossAttackCooldown := false

    ;Credit: @Haie
    color_home := PixelGetColor(10, 10)
    color_reconnect := PixelGetColor(519,329)
    if (color_home == 0x121215 or color_reconnect == 0x393B3D) {
        AddToLog("Disconnected! Attempting to reconnect...")
        ;sendDCWebhook()

        inStage := false
        if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
            autoAbilityClicking := false
            SetTimer(AutoAbility_ClickLoop, 0)
            SendInput("{T}")
            Sleep(200)
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
                global inBossAttackMode := false, BossAttackStartTime := A_TickCount, BossAttackMapIndex := 1 BossAttackMapStegeCount := 0, BossAttackMapIndex := 1
                global justHitBossAttackCooldown := false
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
                global inBossAttackMode := false, BossAttackStartTime := A_TickCount, BossAttackMapIndex := 1 BossAttackMapStegeCount := 0, BossAttackMapIndex := 1
                global justHitBossAttackCooldown := false
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

    inStage := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
    }

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

    inStage := false
    if (IsSet(autoAbilityClicking) && autoAbilityClicking) {
        autoAbilityClicking := false
        SetTimer(AutoAbility_ClickLoop, 0)
        SendInput("{T}")
        Sleep(200)
    }

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
    global inChallengeMode, firstStartup, challengeStartTime, inBossAttackMode, justHitBossAttackCooldown, currentMap, startingMode
    global BossAttackStartTime, StartupBossAttack

    inStage := false
    autoAbilityClicking := false

    FixClick(640, 70) ; Closes Player leaderboard
    Sleep(500)

    FixClick(558, 166) ; Closes Daily
    Sleep (500)

    if (ModeDropdown.Text = "Co-op") {
        inChallengeMode := false
        inBossAttackMode := false
        firstStartup := false
        CoOpMode()
        return
    }

    if (firstStartup) {
        justHitBossAttackCooldown := false
        if (BossAttackBox.Value) {
            AddToLog("Auto Boss Attack enabled - starting with Boss Attack")
            inBossAttackMode := true
            inChallengeMode := false
            firstStartup := false
            BossAttackStartTime := A_TickCount
            challengeStartTime := A_TickCount
            BossAttackMapStegeCount := 0
            BossAttack()
            return
        }
        firstStartup := false 
    }
    
    if (justHitBossAttackCooldown) {
        AddToLog("Boss Attack recently on cooldown. Defaulting to dropdown mode.")
    } else if (inBossAttackMode) {
        AddToLog("Continuing/Starting Boss Attack")
        BossAttack()
        return
    }
    
    AddToLog("Starting mode: " ModeDropdown.Text)
    if (ModeDropdown.Text = "Story") {
        StartContent(StoryDropdown.Text, StoryActDropdown.Text, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
    } else if (ModeDropdown.Text = "Ranger Stages") {
        StartContent(RangerMapDropdown.Text, RangerActDropdown.Text, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
    } else if (ModeDropdown.Text = "Raid") {
        StartContent(RaidDropdown.Text, RaidActDropdown.Text, GetRaidMap, GetRaidAct, { x: 230, y: 155 }, { x: 405, y: 195 })
    } else if (ModeDropdown.Text = "Boss Event") {
        BossEvent()
    } else if (ModeDropdown.Text = "Challenge") {
        ChallengeMode()
    } else if (ModeDropdown.Text = "Portal") {
        Portal()
    } else if (ModeDropdown.Text = "Infinity Castle") {
        StartInfinityCastle()
    } else if (ModeDropdown.Text = "Boss Rush") {
        StartBossRush()
    } else if (ModeDropdown.Text = "Swarm Event") {
        StartSwarmEvent()
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
    maxUpgradeSlots := Map()

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
                waitUntilMaxSlots[slotNum] := upgradeBeforeSummon.Value ? true : false
            } else {
                maxUpgradeSlots[slotNum] := true
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
        AddToLog("Summon && Upgrade disabled - monitoring stage")
        checkForUnitManager := false
        return
    }

    ; ==== Decide whether to open the Unit Manager ====
    if (upgradeUnits && checkForUnitManager && upgradeEnabledSlots.Count > 0) {
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
                    break
                }
            }
        }
        checkForUnitManager := false
    }

    ; ==== Enable auto ability logic ====
    inStage := true
    if (AutoAbility.Value && inStage && !IsInLobby()) {
        autoAbilityClicking := true
        AutoAbilityRoutine()
    }

    lastScrollGroup := ""
    lastSlotNum := ""

    ; Main loop — runs until all enabled slots are processed
    while (enabledSlots.Length > 0) {
        if (CheckForXp()) {
            return
        }
        ; Track whether any upgrading was done this loop
        upgradedThisLoop := false

        ; Summon maxed units first
       /* for index, slotNum in enabledSlots {
            SummonIfReady(slotNum, waitUntilMaxSlots, maxUpgradeSlots)
        } */
    
        ; Handle upgrading (only one unit at a time if toggle is on)
        if (upgradeUnits && upgradeEnabledSlots.Count > 0) {
            for index, slotNum in enabledSlots {
                
                if !upgradeEnabledSlots.Has(slotNum)
                    continue
    
                if CheckForXp() {
                    return
                }

                VoteCheck()
    
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

                AddToLog("Upgrading unit in slot: " slotNum)

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
                    maxUpgradeSlots[slotNum] := true
                    waitUntilMaxSlots.Delete(slotNum) ; Remove from wait list
                }

                for _, slotNum in enabledSlots {
                    SummonIfReady(slotNum, waitUntilMaxSlots, maxUpgradeSlots)
                }

                Reconnect()

                ; Break if we're only doing one unit at a time
                if (UpgradeUntilMaxed.Value) {
                    break
                }
            }
        } else {

            ; Now summon all enabled units
            for _, slotNum in enabledSlots {

                if CheckForXp() {
                    return
                }
                VoteCheck()
                SummonIfReady(slotNum, waitUntilMaxSlots, maxUpgradeSlots)
            }
            Reconnect()
        }
    }    
}

ShouldSummon(slotNum, waitUntilMaxSlots, maxUpgradeSlots) {
    ; If not set to wait until maxed → summon
    if (!waitUntilMaxSlots.Has(slotNum)) {
        return true
    }

    ; If it IS set to wait until maxed
    if (waitUntilMaxSlots[slotNum]) {
        return maxUpgradeSlots.Has(slotNum)
    }

    ; Otherwise, summon as normal
    return true
}

SummonIfReady(slotNum, waitUntilMaxSlots, maxUpgradeSlots) {
    if (ShouldSummon(slotNum, waitUntilMaxSlots, maxUpgradeSlots)) {
        Reconnect()
        if (AutoPlay.Value) {
            SendInput("{" slotNum "}")
            FixClick(390, 500)
            AddToLog("Summoning unit in slot: " slotNum)
        }
    } else if (debugMessages) {
        AddToLog("Skipping summon for slot " slotNum)
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
    AddToLog("Co-op mode selected. Skipping map detection.")
    inStage := true
    autoAbilityClicking := true
    startingMode := false
}

; After win/loss detection, search for special text for up to 10 seconds and click it if found
    t1 := A_TickCount, Text := X := Y := ""
    Text := "|<>**50$29.QQ1U1ww7U3PDBb6KzvzatXVVAqH6HBBnQaMvatsNkQnEqlxkUwyTzE"
    ok := ""
    Loop {
        if (ok := FindText(&X, &Y, 319, 122, 471, 234, 0, 0, Text))
            break
        if ((A_TickCount - t1) > 10000)
            break
        Sleep(100)
    }
    if (ok) {
        Click X, Y
    }
    Try For i,v in ok  ; ok value can be get from ok:=FindText().ok
        if (i<=2)
            FindText().MouseTip(ok[i].x, ok[i].y)

CanReplay() {
    if (GetFindText().FindText(&X, &Y, 161, 351, 630, 522, 0, 0, Replay)) {
        return true
    }
    
    return false
}

IsInLobby() {
    return GetFindText().FindText(&X, &Y, 4, 299, 91, 459, 0, 0, AreaText)
}

ChangeGameSpeed() {
    if (GameSpeed.Text = "2x") {
        FixClick(569, 23)
    }
    else if (GameSpeed.Text = "3x") {
        FixClick(597, 22) ; 3x Speed
    }
}

ChangePath() {
    AddToLog("Changing " ModeDropdown.Text " Path")
    FixClick(471, 439)
}

ModeValidForMapDetection(mode) {
    ; If the mode is any of these, skip map detection
    excludedModes := ["Co-op", "Swarm Event"]

    for modes, excludedMode in excludedModes {
        if (mode = excludedMode) {
            return false
        }
    }

    return true
}