#Include %A_ScriptDir%\Lib\gui.ahk
#Include %A_ScriptDir%\Main.ahk
#Include %A_ScriptDir%\Lib\MapSkips.ahk

SaveMapSkipConfig(*) {
    SaveMapSkipLocal
    return
}

LoadMapSkipConfig(*) {
    LoadMapSkipLocal
    return
}

SaveMapSkipConfigToFile(filePath) {
    directory := "Settings"

    if !DirExist(directory) {
        DirCreate(directory)
    }
    if !FileExist(filePath) {
        FileAppend("", filePath)
    }

    File := FileOpen(filePath, "w")
    if !File {
        AddToLog("Failed to save the map configuration.")
        return
    }

    File.WriteLine("[SkippedMaps]")
    for index, mapDropDown in mapDropDowns {
        File.WriteLine(Format("Map{}={}", index+1, mapDropDown.Text))
    }
    File.WriteLine("[SkippedActs]")
    for index, actDropDown in actDropDowns {
        File.WriteLine(Format("Map{}={}", index+1, actDropDown.Text))
    }

    File.Close()
    if (debugMessages) {
        AddToLog("Map+Act configuration saved to " filePath ".`n")
    }
}

LoadMapSkipConfigFromFile(filePath) {
    global mapDropDowns, actDropDowns, mapSkipPriorityOrder, actSkipPriorityOrder

    if !FileExist(filePath) {
        AddToLog("No map skip configuration file found. Creating new local configuration.")
        SaveMapSkipLocal()
    } else {
        file := FileOpen(filePath, "r", "UTF-8")
        if !file {
            AddToLog("Failed to load the configuration.")
            return
        }

        section := ""
        while !file.AtEOF {
            line := file.ReadLine()

            if RegExMatch(line, "^\[(.*)\]$", &match) {
                section := match.1
                continue
            }

            if (section = "SkippedMaps") {
                if RegExMatch(line, "Map(\d+)=(.*)", &match) {
                    slot := match.1
                    value := match.2

                    mapSkipPriorityOrder[slot - 1] := value

                    mapDropDown := mapDropDowns[slot - 1]
                    if (mapDropDown) {
                        mapDropDown.Text := value
                    }
                }
            } else if (section = "SkippedActs") {
                if RegExMatch(line, "Map(\d+)=(.*)", &match) {
                    slot := match.1
                    value := match.2

                    actSkipPriorityOrder[slot - 1] := value

                    actDropDown := actDropDowns[slot - 1]
                    if (actDropDown) {
                        actDropDown.Text := value
                    }
                }
            }
        }
        file.Close()
        UpdateEnabledMapSkips()
        if (debugMessages) {
            AddToLog("Map+Act configuration loaded successfully.")
        }
    }
}

SaveMapSkipLocal(*) {
    SaveMapSkipConfigToFile("Settings\SkippedMaps.txt")
}

LoadMapSkipLocal(*) {
    LoadMapSkipConfigFromFile("Settings\SkippedMaps.txt")
    UpdateEnabledMapSkips()
}