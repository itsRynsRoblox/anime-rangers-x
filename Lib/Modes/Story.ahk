#Requires AutoHotkey v2.0

GetStoryMap(map) {
    switch map {
        case "Voocha Village": return { x: 230, y: 165, scrolls: 0 }
        case "Green Planet": return { x: 230, y: 230, scrolls: 0 }
        case "Demon Forest": return { x: 230, y: 290, scrolls: 0 }
        case "Leaf Village": return { x: 230, y: 360, scrolls: 0 }

        case "Z City": return { x: 230, y: 270, scrolls: 1 }
        case "Ghoul City": return { x: 230, y: 345, scrolls: 1 }

        case "Night Colosseum": return { x: 230, y: 265, scrolls: 2 }
        case "Bizzare Race": return { x: 230, y: 330, scrolls: 2 }

        case "Spirit Realm": return { x: 230, y: 255, scrolls: 3 }
        case "The City": return { x: 230, y: 315, scrolls: 3 }

        case "Virtual Sword": return { x: 230, y: 230, scrolls: 4 }
        case "Ruined Future City": return { x: 230, y: 295, scrolls: 4 }

        case "Lake Of Sacrifice": return { x: 230, y: 305, scrolls: 5 }
        case "S Rank Dungeon": return { x: 230, y: 365, scrolls: 5 }
    }
}

GetStoryAct(act) {
    switch act {
        case "Act 1": return { x: 400, y: 180, scrolls: 0 }
        case "Act 2": return { x: 400, y: 245, scrolls: 0 }
        case "Act 3": return { x: 400, y: 300, scrolls: 0 }
        case "Act 4": return { x: 400, y: 225, scrolls: 1 }
        case "Act 5": return { x: 400, y: 275, scrolls: 1 }
        case "Act 6": return { x: 400, y: 200, scrolls: 2 }
        case "Act 7": return { x: 400, y: 250, scrolls: 2 }
        case "Act 8": return { x: 400, y: 300, scrolls: 2 }
        case "Act 9": return { x: 400, y: 235, scrolls: 3 }
        case "Act 10": return { x: 400, y: 290, scrolls: 3 }
    }
}