global RangerMenu := Gui("+AlwaysOnTop")
RangerMenu.SetFont("s10 bold", "Segoe UI")
RangerMenu.BackColor := "0c000a"
RangerMenu.MarginX := 20
RangerMenu.MarginY := 20
RangerMenu.Title := "Ranger Options"

RangerOptions := RangerMenu.Add("GroupBox", "x30 y25 w180 h260 +Center cWhite", "Ranger Settings")

rangerOptions := ["None", "Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]

numDropDowns := (rangerOptions.Length - 1)
yStart := 50
ySpacing := 28

global rangerDropDowns := []
global enabledRangerOptions := []

Loop numDropDowns {
    yPos := yStart + ((A_Index - 1) * ySpacing)
    dropDown := RangerMenu.Add("DropDownList", Format("x50 y{} w135 Choose1", yPos), rangerOptions)
    rangerDropDowns.Push(dropDown)
    AttachDropDownEvent(dropDown, A_Index, OnRangerDropDownChange)
}

OpenRangerMenu() {
    RangerMenu.Show()
}

global rangerOptionsOrder := []

Loop numDropDowns {
    rangerOptionsOrder.Push("None")
}

OnRangerDropDownChange(ctrl, index) {
    if (index >= 0 and index <= 19) {
        rangerOptionsOrder[index] := ctrl.Text
        if (debugMessages) {
            AddToLog(Format("Ranger Option {} set to {}", index, ctrl.Text))
        }
        RemoveEmptyStrings(rangerOptionsOrder)
        UpdateEnabledRangerOptions()
        SaveRangerOptionsLocal()
    } else {
        if (debugMessages) {
            AddToLog(Format("Invalid index {} for dropdown", index))
        }
    }
}

UpdateEnabledRangerOptions() {
    global enabledRangerOptions
    enabledRangerOptions := []
    for index, option in rangerOptionsOrder {
        if (option != "" and option != "None") {
            enabledRangerOptions.Push(option)
        }
    }
}

SaveRangerOptionsLocal() {
    ; TODO: Implement saving ranger options to a local file
}

IsRangerOptionEnabled(option) {
    global enabledRangerOptions
    return HasValue(enabledRangerOptions, option)
} 