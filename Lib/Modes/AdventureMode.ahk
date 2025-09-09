#Requires AutoHotkey v2.0

CheckForContinue() {
    return GetFindText().FindText(&X, &Y, 176, 172, 325, 219, 0, 0, ContinueRun)
}

HandleEndureOrEvade() {
    global enduresPerRun
    if (CheckForContinue()) {
        if (enduresPerRun == MaxEndures.Value) {
            AddToLog("Reached max endures, evading instead")
            FixClick(450, 395)
            enduresPerRun := 0
        } else {
            FixClick(325, 395)
            enduresPerRun++
            AddToLog(Format("Endured {}/{} times this run" (enduresPerRun == MaxEndures.Value ? " and will evade next time" : ""), enduresPerRun, MaxEndures.Value))
        }
        return true
    }
    return false
}
