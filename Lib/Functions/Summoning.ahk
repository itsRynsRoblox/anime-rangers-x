#Requires AutoHotkey v2.0

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