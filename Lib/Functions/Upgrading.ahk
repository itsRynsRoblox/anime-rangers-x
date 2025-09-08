#Requires AutoHotkey v2.0

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

MaxUpgraded() {
    Sleep 500
    ; Check for max text
    if (ok := GetFindText().FindText(&X, &Y, 108, 246, 158, 263, 0, 0, UnitMaxText)) {
        return true
    }
    return false
}

HandleAutoAbilityUnitManager() {
    if !AutoAbility.Value
        return

    ; Search area
    searchLeft := 551
    searchTop := 181
    searchWidth := 787 - searchLeft
    searchHeight := 445 - searchTop

    ; Target pixel color
    color := 0xFFFFFF ; White color

    ; Search grid
    while (PixelSearch(&x, &y, searchLeft, searchTop, searchLeft + searchWidth, searchTop + searchHeight, color, 20)) {
        AddToLog("Found white pixel at " . x . ", " . y)
        FixClick(x, y)
        Sleep(100)
    }
}