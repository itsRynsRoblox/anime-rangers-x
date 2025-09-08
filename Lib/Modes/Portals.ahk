#Requires AutoHotkey v2.0

GetMapForFarming(name) {
    farmMap := Map(
        "Ghoul City Portal", "Ghoul City",
        "Ghoul City", "Ghoul City Portal"
    )
    if (farmMap.Has(name)) {
        return farmMap[name]
    } else {
        return "no map found"
    }
}

SetMapForPortalFarm(name) {
    return StoryDropdown.Text := name
}

SwitchActiveFarm() {
    global mode
    if (ModeDropdown.Text = "Story") {
        newMap := GetMapForFarming(StoryDropdown.Text)
        if (newMap != "no map found") {
            ModeDropdown.Text := "Portal"
            PortalDropdown.Text := newMap
            mode := "Portal"
            AddToLog("Switched to " newMap)
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Portal: " PortalDropdown.Text)
            }
        } else {
            if (debugMessages) {
                AddToLog("No valid portal mapping found for " StoryDropdown.Text)
            }
        }
    } else {
        newMap := GetMapForFarming(PortalDropdown.Text)
        if (newMap != "no map found") {
            ModeDropdown.Text := "Story"
            StoryActDropdown.Text := "Act 10"
            StoryDropdown.Text := newMap
            mode := "Story"
            AddToLog("Switched to " newMap " for farming portals")
            if (debugMessages) {
                AddToLog("Mode: " ModeDropdown.Text)
                AddToLog("Story Act: " StoryActDropdown.Text)
                AddToLog("Story: " StoryDropdown.Text)
            }
        } else {
            if (debugMessages) {
                AddToLog("No valid story mapping found for " PortalDropdown.Text)
            }
        }
    }
}

RemovePortalName() {
    FixClick(377, 196)
    loop 30 {
        SendInput ("{BackSpace}")
        Sleep(20)
    }
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