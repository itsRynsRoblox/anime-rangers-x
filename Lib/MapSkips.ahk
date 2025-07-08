global MapSkipPrioritySelector := Gui("+AlwaysOnTop")
MapSkipPrioritySelector.SetFont("s10 bold", "Segoe UI")
MapSkipPrioritySelector.BackColor := "0c000a"
MapSkipPrioritySelector.MarginX := 20
MapSkipPrioritySelector.MarginY := 20
MapSkipPrioritySelector.Title := "Ranger Maps"

MapSkipPriorityOrder := MapSkipPrioritySelector.Add("GroupBox", "x30 y25 w250 h260 +Center cWhite", "Select Ranger Maps and Act to Play")

; ปรับ mapOptions เป็น array ซ้อน (แต่ละแผนที่มีชื่อจริงเป็น index 2)
mapOptions := [
    ["None", "Voocha Village"], 
    ["None", "Green Planet"], 
    ["None", "Demon Forest"], 
    ["None", "Leaf Village"], 
    ["None", "Z City"], 
    ["None", "Ghoul City"], 
    ["None", "Night Colosseum"]
]

; mapActOptions index ตรงกับ mapOptions
mapActOptions := [
    ["None", "Act 1", "Act 2", "Act 3"], ; Voocha Village
    ["None", "Act 1", "Act 2", "Act 3"], ; Green Planet
    ["None", "Act 1", "Act 2", "Act 3"], ; Demon Forest
    ["None", "Act 1", "Act 2", "Act 3"], ; Leaf Village
    ["None", "Act 1", "Act 2", "Act 3"], ; Z City
    ["None", "Act 1", "Act 2", "Act 3", "Act 4", "Act 5"], ; Ghoul City
    ["None", "Act 1", "Act 2", "Act 3"]  ; Night Colosseum
]

numDropDowns := mapOptions.Length

global mapDropDowns := []
global actDropDowns := []
global enabledMapSkips := []

yStart := 50
ySpacing := 28

Loop numDropDowns {
    yPos := yStart + ((A_Index - 1) * ySpacing)
    mapDrop := MapSkipPrioritySelector.Add("DropDownList", Format("x50 y{} w135 Choose1", yPos), mapOptions[A_Index])
    mapDropDowns.Push(mapDrop)
    actDrop := MapSkipPrioritySelector.Add("DropDownList", Format("x200 y{} w60 Choose1", yPos), mapActOptions[A_Index])
    actDropDowns.Push(actDrop)
    AttachDropDownEvent(mapDrop, A_Index, OnMapDropDownChange)
    AttachDropDownEvent(actDrop, A_Index, OnActDropDownChange)
}

OpenMapSkipPriorityPicker() {
    MapSkipPrioritySelector.Show()
}

global mapSkipPriorityOrder := []
global actSkipPriorityOrder := []
Loop numDropDowns {
    mapSkipPriorityOrder.Push("None")
    actSkipPriorityOrder.Push("None")
}

OnMapDropDownChange(ctrl, index) {
    global mapSkipPriorityOrder
    mapSkipPriorityOrder[index] := ctrl.Text
    if (debugMessages) {
        AddToLog(Format("Map {} set to {}", index, ctrl.Text))
    }
    RemoveEmptyStrings(mapSkipPriorityOrder)
    UpdateEnabledMapSkips()
    SaveMapSkipLocal
}

OnActDropDownChange(ctrl, index) {
    global actSkipPriorityOrder
    actSkipPriorityOrder[index] := ctrl.Text
    if (debugMessages) {
        AddToLog(Format("Act {} set to {}", index, ctrl.Text))
    }
    ; สามารถเพิ่ม logic อื่นๆ ได้ เช่น save หรือ update
    UpdateEnabledMapSkips()
    SaveMapSkipLocal()
}

UpdateEnabledMapSkips() {
    global enabledMapSkips, mapSkipPriorityOrder, actSkipPriorityOrder
    enabledMapSkips := []
    for index, map in mapSkipPriorityOrder {
        act := actSkipPriorityOrder[index]
        if (map != "" and map != "None" and act != "" and act != "None") {
            enabledMapSkips.Push({map: map, act: act})
        }
    }
}

; ถ้า map/act ไม่ได้อยู่ใน enabledMapSkips ให้ข้าม
ShouldSkipMap(map, act) {
    global enabledMapSkips
    for _, skip in enabledMapSkips {
        if (skip.map = map && skip.act = act) {
            return false ; "เจอ" = ไม่ข้าม (เล่น)
        }
    }
    return true ; "ไม่เจอ" = ข้าม
}