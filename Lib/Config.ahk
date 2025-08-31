#Include %A_ScriptDir%\Lib\GUI.ahk
global settingsFile := "" 


setupFilePath() {
    global settingsFile
    
    if !DirExist(A_ScriptDir "\Settings") {
        DirCreate(A_ScriptDir "\Settings")
    }

    settingsFile := A_ScriptDir "\Settings\Configuration.txt"
    return settingsFile
}

readInSettings() {
    ; General settings
    global mode

    try {
        settingsFile := setupFilePath()
        if !FileExist(settingsFile) {
            return
        }

        content := FileRead(settingsFile)
        lines := StrSplit(content, "`n")
        
        for line in lines {
            if line = "" {
                continue
            }
            
            parts := StrSplit(line, "=")
            switch parts[1] {
                case "Mode": mode := parts[2]

                case "Enabled1": enabled1.Value := parts[2]
                case "Enabled2": enabled2.Value := parts[2]
                case "Enabled3": enabled3.Value := parts[2]
                case "Enabled4": enabled4.Value := parts[2]
                case "Enabled5": enabled5.Value := parts[2]
                case "Enabled6": enabled6.Value := parts[2]
                case "Placement1": placement1.Text := parts[2]
                case "Placement2": placement2.Text := parts[2]
                case "Placement3": placement3.Text := parts[2]
                case "Placement4": placement4.Text := parts[2]
                case "Placement5": placement5.Text := parts[2]
                case "Placement6": placement6.Text := parts[2]
                case "UpgradeEnabled1": upgradeEnabled1.Value := parts[2]
                case "UpgradeEnabled2": upgradeEnabled2.Value := parts[2]
                case "UpgradeEnabled3": upgradeEnabled3.Value := parts[2]
                case "UpgradeEnabled4": upgradeEnabled4.Value := parts[2]
                case "UpgradeEnabled5": upgradeEnabled5.Value := parts[2]
                case "UpgradeEnabled6": upgradeEnabled6.Value := parts[2]
                case "UpgradeBeforeSummon1": upgradeBeforeSummon1.Value := parts[2]
                case "UpgradeBeforeSummon2": upgradeBeforeSummon2.Value := parts[2]
                case "UpgradeBeforeSummon3": upgradeBeforeSummon3.Value := parts[2]
                case "UpgradeBeforeSummon4": upgradeBeforeSummon4.Value := parts[2]
                case "UpgradeBeforeSummon5": upgradeBeforeSummon5.Value := parts[2]
                case "UpgradeBeforeSummon6": upgradeBeforeSummon6.Value := parts[2]

                case "Sleep": LobbySleepTimer.Value := parts[2] ; Set the dropdown value
                case "Matchmake": MatchMaking.Value := parts[2] ; Set the checkbox value
                ;case "Challenge": ChallengeBox.Value := parts[2] ; Set the checkbox value
                case "Next": NextLevelBox.Value := parts[2] ; Set the checkbox value
                case "ToLobby": ReturnLobbyBox.Value := parts[2] ; Set the checkbox value
                case "Replay": ReplayBox.Value := parts[2] ; Set the checkbox value
                case "Difficulty": StoryDifficulty.Value := parts[2] ; Set the dropdown value
                case "BossAttack": BossAttackBox.Value := parts[2] ; Set the checkbox value
                case "Play": AutoPlay.Value := parts[2] ; Set the checkbox value
                case "Upgrade": ShouldUpgradeUnits.Value := parts[2] ; Set the checkbox value
                case "LobbyDelay": LobbySleepTimer.Value := parts[2]
                case "WebhookDelay": WebhookSleepTimer.Value := parts[2]
                case "UpgradeClicks": UpgradeClicks.Value := parts[2]
                case "LoadingScreenDelay": LoadingScreenWaitTime.Value := parts[2]
				;case "RangerCDDelay": RangerCDTimer.Value := parts[2]
                case "Messages": UpdateMessages.Value := parts[2]
                case "AutoAbility": AutoAbility.Value := Number(parts[2])
                case "UltimateCheck": UltimateCheckEdit.Value := parts[2]
                case "UpgradeUntilMaxed": UpgradeUntilMaxed.Value := parts[2]
                case "UpgradeBeforeUltimate": UpgradeBeforeUltimateEdit.Value := parts[2]
                case "BossAttackCDDelay": BossAttackCDTimer.Value := parts[2]
                case "ReturnToLobbyTimer": ReturnToLobbyTimer.Value := parts[2]
                case "InfinityCastleTime": InfinityCastleTime.Value := parts[2]
                case "BossRushTime": BossRushTime.Value := parts[2]
                case "GameSpeed": GameSpeed.Value := parts[2]
                case "AutoPortalFarm": PortalFarm.Value := parts[2]
                case "AutoStart": AutoStart.Value := parts[2]
                case "AutoRetry": AutoRetry.Value := parts[2]
                case "AutoGameSpeed": AutoGameSpeed.Value := parts[2]
                case "WebhookEnabled": WebhookEnabled.Value := parts[2]
                case "WebhookLogsEnabled": WebhookLogsEnabled.Value := parts[2]
                case "WebhookURL": WebhookURLBox.Text := parts[2]
                case "PrivateServerEnabled": PrivateServerEnabled.Value := parts[2]
                case "PrivateServerURL": PrivateServerURLBox.Text := parts[2]
            }
        }
        AddToLog("✅ Configuration settings loaded successfully")
        LoadMapSkipLocal()
    } 
}


SaveSettings(*) {
    ; General settings
    global mode

    try {
        settingsFile := A_ScriptDir "\Settings\Configuration.txt"
        if FileExist(settingsFile) {
            FileDelete(settingsFile)
        }

        ; Save mode and map selection
        content := "Mode=" mode "`n"
        if (mode = "Story") {
            content .= "Map=" StoryDropdown.Text
        } else if (mode = "Raid") {
            content .= "Map=" RaidDropdown.Text
        }
        
        
        ; Save settings for each unit

        content .= "`n[SleepTimer]"
        content .= "`nSleep=" LobbySleepTimer.Value "`n"

        content .= "`n[Matchmaking]"
        content .= "`nMatchmake=" MatchMaking.Value "`n"

        ;content .= "`n[AutoChallenge]"
        ;content .= "`nChallenge=" ChallengeBox.Value "`n"

        content .= "`n[AutoBossAttack]"
        content .= "`nBossAttack=" BossAttackBox.Value "`n"

        content .= "`n[ReturnToLobby]"
        content .= "`nToLobby=" ReturnLobbyBox.Value "`n"

        content .= "`n[Replay]"
        content .= "`nReplay=" ReplayBox.Value "`n"

        content .= "`n[NextLevel]"
        content .= "`nNext=" NextLevelBox.Value "`n"

        content .= "`n[StoryDifficulty]"
        content .= "`nDifficulty=" StoryDifficulty.Value "`n"

        content .= "`n[Autoplay]"
        content .= "`nPlay=" AutoPlay.Value "`n"

        content .= "`n[AutoUpgrade]"
        content .= "`nUpgrade=" ShouldUpgradeUnits.Value "`n"

        ; Save settings for each unit
        content .= "`n[UnitSettings]"
        content .= "`n`nEnabled1=" enabled1.Value
        content .= "`nEnabled2=" enabled2.Value
        content .= "`nEnabled3=" enabled3.Value
        content .= "`nEnabled4=" enabled4.Value
        content .= "`nEnabled5=" enabled5.Value
        content .= "`nEnabled6=" enabled6.Value

        content .= "`n`nPlacement1=" placement1.Text
        content .= "`nPlacement2=" placement2.Text
        content .= "`nPlacement3=" placement3.Text
        content .= "`nPlacement4=" placement4.Text
        content .= "`nPlacement5=" placement5.Text
        content .= "`nPlacement6=" placement6.Text

        ; Create UpgradeEnabled section
        content .= "`n`n[UpgradeEnabled]"
        Loop 6 {
            content .= "`nUpgradeEnabled" A_Index "=" UpgradeEnabled%A_Index%.Value
        }

        content .= "`nUpgradeUntilMaxed=" UpgradeUntilMaxed.Value

        content .= "`n`n[UpgradeBeforeSummoning]"
        Loop 6 {
            content .= "`nUpgradeBeforeSummon" A_Index "=" upgradeBeforeSummon%A_Index%.Value
        }

        content .= "`n`n[Lobby]"
        content .= "`nLobbyDelay=" LobbySleepTimer.Value

        content .= "`n`n[Webhook]"
        content .= "`nWebhookDelay=" WebhookSleepTimer.Value

        content .= "`n[Upgrading]"
        content .= "`nUpgradeClicks=" UpgradeClicks.Value

        content .= "`n[LoadingScreen]"
        content .= "`nLoadingScreenDelay=" LoadingScreenWaitTime.Value
				
        content .= "`n[UpdateMessages]"
        content .= "`nMessages=" UpdateMessages.Value

        content .= "`n[AutoAbility]"
        content .= "`nAutoAbility=" (AutoAbility.Value ? 1 : 0) "`n"

        content .= "`n[TimersCustom]"
        content .= "`nUltimateCheck=" UltimateCheckEdit.Value
        content .= "`nUpgradeBeforeUltimate=" UpgradeBeforeUltimateEdit.Value

		;content .= "`n[RangerCD]"
        ;content .= "`nRangerCDDelay=" RangerCDTimer.Value

        content .= "`n`n[BossAttackCD]"
        content .= "`nBossAttackCDDelay=" BossAttackCDTimer.Value

        content .= "`n`n[ReturnToLobbyTimer]"
        content .= "`nReturnToLobbyTimer=" ReturnToLobbyTimer.Value

        content .= "`n`n[InfinityCastle]"
        content .= "`nInfinityCastleTime=" InfinityCastleTime.Value

        content .= "`n`n[Boss Rush]"
        content .= "`nBossRushTime=" BossRushTime.Value

        content .= "`n`n[Game Speed]"
        content .= "`nGameSpeed=" GameSpeed.Value

        content .= "`n`n[Portals]"
        content .= "`nAutoPortalFarm=" PortalFarm.Value

        content .= "`n`n[AutoStart]"
        content .= "`nAutoStart=" AutoStart.Value

        content .= "`n`n[AutoRetry]"
        content .= "`nAutoRetry=" AutoRetry.Value

        content .= "`n`n[AutoGameSpeed]"
        content .= "`nAutoGameSpeed=" AutoGameSpeed.Value

        content .= "`n`n[WebhookSettings]"
        content .= "`nWebhookEnabled=" WebhookEnabled.Value
        content .= "`nWebhookLogsEnabled=" WebhookLogsEnabled.Value
        content .= "`nWebhookURL=" WebhookURLBox.Text

        content .= "`n`n[PrivateServerSettings]"
        content .= "`nPrivateServerEnabled=" PrivateServerEnabled.Value
        content .= "`nPrivateServerURL=" PrivateServerURLBox.Text
		
        FileAppend(content, settingsFile)
        AddToLog("✅ Configuration settings saved successfully")
        SaveMapSkipLocal()
    }
}

SaveKeybindSettings(*) {
    AddToLog("Saving Keybind Configuration")
    
    if FileExist("Settings\Keybinds.txt")
        FileDelete("Settings\Keybinds.txt")
        
    FileAppend(Format("F1={}`nF2={}`nF3={}`nF4={}", F1Box.Value, F2Box.Value, F3Box.Value, F4Box.Value), "Settings\Keybinds.txt", "UTF-8")
    
    ; Update globals
    global F1Key := F1Box.Value
    global F2Key := F2Box.Value
    global F3Key := F3Box.Value
    global F4Key := F4Box.Value
    
    ; Update hotkeys
    Hotkey(F1Key, (*) => moveRobloxWindow())
    Hotkey(F2Key, (*) => StartMacro())
    Hotkey(F3Key, (*) => Reload())
    Hotkey(F4Key, (*) => TogglePause())
}

LoadKeybindSettings() {
    if FileExist("Settings\Keybinds.txt") {
        fileContent := FileRead("Settings\Keybinds.txt", "UTF-8")
        Loop Parse, fileContent, "`n" {
            parts := StrSplit(A_LoopField, "=")
            if (parts[1] = "F1")
                global F1Key := parts[2]
            else if (parts[1] = "F2")
                global F2Key := parts[2]
            else if (parts[1] = "F3")
                global F3Key := parts[2]
            else if (parts[1] = "F4")
                global F4Key := parts[2]
        }
    }
}