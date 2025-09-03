#Requires AutoHotkey v2.0

GetRaidMap(map) {
    switch map {
        case "Steel Blitz Rush": return { x: 230, y: 165, scrolls: 0 }
        case "The Graveyard": return { x: 230, y: 230, scrolls: 0 }
        case "The Gated City": return { x: 230, y: 290, scrolls: 0 }
    }
}

GetRaidAct(act) {
    switch act {
        case "Act 1": return { x: 400, y: 191, scrolls: 0 }
        case "Act 2": return { x: 400, y: 245, scrolls: 0 }
        case "Act 3": return { x: 400, y: 305, scrolls: 0 }
        case "Act 4": return { x: 400, y: 305, scrolls: 1 }
    }
}
