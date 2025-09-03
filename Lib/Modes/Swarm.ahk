#Requires AutoHotkey v2.0

StartSwarmEvent() {
    global startingMode
    FixClick(780, 215) ; Click Swarm Event button
    Sleep(1000)
    FixClick(218, 445) ; Click Play
    startingMode := false
    return true
}