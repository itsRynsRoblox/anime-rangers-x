global MapSkipPrioritySelector := Gui("+AlwaysOnTop")
MapSkipPrioritySelector.SetFont("s10 bold", "Segoe UI")
MapSkipPrioritySelector.BackColor := "0c000a"
MapSkipPrioritySelector.MarginX := 20
MapSkipPrioritySelector.MarginY := 20
MapSkipPrioritySelector.Title := "Ranger Maps"

MapSkipPriorityOrder := MapSkipPrioritySelector.Add("GroupBox", "x30 y25 w180 h260 +Center cWhite", "Skipped Ranger Maps")

mapOptions := ["None", "Voocha Village", "Green Planet", "Demon Forest", "Leaf Village", "Z City"]

numDropDowns := 5
yStart := 50
ySpacing := 28

global mapDropDowns := []
global enabledMapSkips := []

Loop numDropDowns {
    yPos := yStart + ((A_Index - 1) * ySpacing)
    dropDown := MapSkipPrioritySelector.Add("DropDownList", Format("x50 y{} w135 Choose1", yPos), mapOptions)
    mapDropDowns.Push(dropDown)
    AttachDropDownEvent(dropDown, A_Index, OnMapDropDownChange)
}

OpenMapSkipPriorityPicker() {
    MapSkipPrioritySelector.Show()
}

global mapSkipPriorityOrder := []

Loop numDropDowns {
    mapSkipPriorityOrder.Push("None")
}

OnMapDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        mapSkipPriorityOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Map {} set to {}", index, ctrl.Text))
        }
        RemoveEmptyStrings(mapSkipPriorityOrder)
        UpdateEnabledMapSkips()
        SaveMapSkipLocal
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}

UpdateEnabledMapSkips() {
    global enabledMapSkips
    enabledMapSkips := []
    for index, map in mapSkipPriorityOrder {
        if (map != "" and map != "None") {
            enabledMapSkips.Push(map)
        }
    }
}

ShouldSkipMap(map) {
    global enabledMapSkips
    return HasValue(enabledMapSkips, map)
}