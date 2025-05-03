#Include %A_ScriptDir%\Lib\GUI.ahk
global confirmClicked := false

SavePsSettings(*) {
    AddToLog("Saving Private Server")
    
    if FileExist("Settings\PrivateServer.txt")
        FileDelete("Settings\PrivateServer.txt")
    
    FileAppend(PsLinkBox.Value, "Settings\PrivateServer.txt", "UTF-8")
}

SaveUINavSettings(*) {
    AddToLog("Saving UI Navigation Key")
    
    if FileExist("Settings\UINavigation.txt")
        FileDelete("Settings\UINavigation.txt")
    
    FileAppend(UINavBox.Value, "Settings\UINavigation.txt", "UTF-8")
}

;Opens discord Link
OpenDiscordLink() {
    Run("https://discord.gg/mistdomain")
 }
 
 ;Minimizes the UI
 minimizeUI(*){
    arMainUI.Minimize()
 }
 
 Destroy(*){
    arMainUI.Destroy()
    ExitApp
 }
 ;Login Text
 setupOutputFile() {
     content := "`n==" aaTitle "" version "==`n  Start Time: [" currentTime "]`n"
     FileAppend(content, currentOutputFile)
 }
 
 getCurrentTime() {
    currentHour := A_Hour
    currentMinute := A_Min
    currentSecond := A_Sec
    amPm := (currentHour >= 12) ? "PM" : "AM"
    
    ; Convert to 12-hour format
    currentHour := Mod(currentHour - 1, 12) + 1

    return Format("{:d}:{:02}:{:02} {}", currentHour, currentMinute, currentSecond, amPm)
}



 OnModeChange(*) {
    global mode
    selected := ModeDropdown.Text
    
    ; Hide all dropdowns first
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    MatchMaking.Visible := false
    ReturnLobbyBox.Visible := false

    
    if (selected = "Story") {
        StoryDropdown.Visible := true
        StoryActDropdown.Visible := true
        mode := "Story"
    } else if (selected = "Legend") {
        LegendDropDown.Visible := true
        LegendActDropdown.Visible := true
        mode := "Legend"
    } else if (selected = "Raid") {
        RaidDropdown.Visible := true
        RaidActDropdown.Visible := true
        mode := "Raid"
    } else if (selected = "Infinity Castle") {
        InfinityCastleDropdown.Visible := true
        mode := "Infinity Castle"
    }
}

OnStoryChange(*) {
    if (StoryDropdown.Text != "") {
        StoryActDropdown.Visible := true
    } else {
        StoryActDropdown.Visible := false
    }
}

OnStoryActChange(*) {

}

OnLegendChange(*) {
    if (LegendDropDown.Text != "") {
        LegendActDropdown.Visible := true
    } else {
        LegendActDropdown.Visible := false
    }
}

OnRaidChange(*) {
    if (RaidDropdown.Text != "") {
        RaidActDropdown.Visible := true
    } else {
        RaidActDropdown.Visible := false
    }
}

OnConfirmClick(*) {
    if (ModeDropdown.Text = "") {
        AddToLog("Please select a gamemode before confirming")
        return
    }

    ; For Story mode, check if both Story and Act are selected
    if (ModeDropdown.Text = "Story") {
        if (StoryDropdown.Text = "" || StoryActDropdown.Text = "") {
            AddToLog("Please select both Story and Act before confirming")
            return
        }
        AddToLog("Selected " StoryDropdown.Text " - " StoryActDropdown.Text)
        mode := "Story"
        MatchMaking.Visible := false
        NextLevelBox.Visible := (StoryActDropdown.Text != "Infinity")
        StoryDifficulty.Visible := (StoryActDropdown.Text != "Infinity")
        StoryDifficultyText.Visible := (StoryActDropdown.Text != "Infinity")
    }
    else if (ModeDropdown.Text = "Boss Event") {
        mode := "Boss Event"
        AddToLog("Selected Boss Event")
    }
    else if (ModeDropdown.Text = "Challenge") {
        mode := "Challenge"
        AddToLog("Selected Challenge Mode")
    }
    else if (ModeDropdown.Text = "Easter Event") {
        mode := "Easter Event"
        AddToLog("Selected Easter Event")
        ReturnLobbyBox.Visible := true
    }
    ; For Legend mode, check if both Legend and Act are selected
    else if (ModeDropdown.Text = "Legend") {
        if (LegendDropDown.Text = "" || LegendActDropdown.Text = "") {
            AddToLog("Please select both Legend Stage and Act before confirming")
            return
        }
        mode := "Legend"
        AddToLog("Selected " LegendDropDown.Text " - " LegendActDropdown.Text)
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
    ; For Raid mode, check if both Raid and RaidAct are selected
    else if (ModeDropdown.Text = "Raid") {
        if (RaidDropdown.Text = "" || RaidActDropdown.Text = "") {
            AddToLog("Please select both Raid and Act before confirming")
            return
        }
        mode := "Raid"
        AddToLog("Selected " RaidDropdown.Text " - " RaidActDropdown.Text)
        MatchMaking.Visible := true
        ReturnLobbyBox.Visible := true
    }
    ; For Infinity Castle, check if mode is selected
    else if (ModeDropdown.Text = "Infinity Castle") {
    if (InfinityCastleDropdown.Text = "") {
        AddToLog("Please select an Infinity Castle difficulty before confirming")
        return
    }
    mode := "Infinity Castle"
    AddToLog("Selected Infinity Castle - " InfinityCastleDropdown.Text)
    MatchMaking.Visible := false  
    } else {
        mode := ModeDropdown.Text
        AddToLog("Selected " ModeDropdown.Text " mode")
        MatchMaking.Visible := false
    }

    ; Hide all controls if validation passes
    ModeDropdown.Visible := false
    StoryDropdown.Visible := false
    StoryActDropdown.Visible := false
    LegendDropDown.Visible := false
    LegendActDropdown.Visible := false
    RaidDropdown.Visible := false
    RaidActDropdown.Visible := false
    InfinityCastleDropdown.Visible := false
    ConfirmButton.Visible := false
    modeSelectionGroup.Visible := false
    Hotkeytext.Visible := true
    Hotkeytext2.Visible := true
    global confirmClicked := true
}


FixClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(50)
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

OpenDiscord() {
    Run("https://discord.gg/mistdomain")
}

SearchFor(Name) {
    FindTexts := Map()

    ; Check if the FindText exists in the map
    if !FindTexts.Has(Name) {
        AddToLog("Error: Couldn't find " Name "...")
        return false  ; Invalid name
    }

    coords := FindTexts[Name].coords
    searchTexts := FindTexts[Name].searchTexts
    x1 := coords[1], y1 := coords[2], x2 := coords[3], y2 := coords[4]

    ; Loop through all search texts to perform the Find Text search
    for searchText in searchTexts {
        if (FindText(&X, &Y, x1, y1, x2, y2, 0.20, 0.20, searchText)) {
            return true  ; FindText found
        }
    }

    return false  ; FindText not found
}

WaitFor(Name, timeout := 5000) {
    startTime := A_TickCount  ; Get current time

    ; **Wait for the FindText to appear**
    Loop {
        if (SearchFor(Name)) {
            if (debugMessages) {
                AddToLog("✅ " Name " detected, proceeding...")
            }
            return true  ; Interface found, exit loop
        }
        if ((A_TickCount - startTime) > timeout) {
            if (debugMessages) {
                AddToLog("⚠ " Name " was not found in time.")
            }
            return false  ; Exit if timeout reached
        }
        Sleep 100  ; Fast checks for better responsiveness
    }
}

HasValue(array, value) {
    for index, element in array {
        if (element = value) {
            return true
        }
    }
    return false
}

AttachDropDownEvent(dropDown, index, callback) {
    dropDown.OnEvent("Change", (*) => callback(dropDown, index))
}

RemoveEmptyStrings(array) {
    loop array.Length {
        i := array.Length - A_Index + 1
        if (array[i] = "") {
            array.RemoveAt(i)
        }
    }
}

StringJoin(array, delimiter := ", ") {
    result := ""
    ; Convert the array to an Object to make it enumerable
    for index, value in array {
        if (index > 1)
            result .= delimiter
        result .= value
    }
    return result
}

GetMousePos() {
    MouseGetPos(&x, &y)
    A_Clipboard := ""  ; Clear the clipboard first
    ClipWait(0.5)  ; Optional: wait for it to clear

    A_Clipboard := x ", " y
    ClipWait(0.5)  ; Wait for the clipboard to be ready

    if (A_Clipboard = x ", " y) {
        AddToLog("Copied: " x ", " y)
    } else {
        AddToLog("Failed to copy coordinates.")
    }
}

ScrollToBottom() {
    loop 3 {
        SendInput("{WheelDown}")
        Sleep(250)
    }
}

ScrollToTop() {
    loop 3 {
        SendInput("{WheelUp}")
        Sleep(50)
    }
}

TeleportToSpawn() {
    FixClick(18, 574) ; Click Settings
    Sleep(1000)
    FixClick(539, 290)
    Sleep(1000)
    FixClick(180, 574) ; Click Settings to close
    Sleep(1000)
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

GetWebhookDelay() {
    speeds := [0, 60000, 180000, 300000, 600000]  ; Array of sleep values
    speedIndex := WebhookSleepTimer.Value  ; Get the selected speed value

    if speedIndex is number  ; Ensure it's a number
        return speeds[speedIndex]  ; Use the value directly from the array
}

CheckForVoteScreen() {
    if (ok := FindText(&X, &Y, 355, 168, 450, 196, 0.10, 0.10, VoteStart)) {
        FixClick(400, 150)
        return true
    }
}