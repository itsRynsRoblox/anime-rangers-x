#Requires AutoHotkey v2.0

StartRangerStages(map, act) {
    return StartContent(map, act, GetStoryMap, GetStoryAct, { x: 230, y: 155 }, { x: 405, y: 195 })
}