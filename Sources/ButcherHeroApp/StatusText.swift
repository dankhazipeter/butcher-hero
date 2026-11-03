import SwiftUI

enum Tone {
    case good,warn,bad
    var color:Color {switch self {case .good:.green;case .warn:.orange;case .bad:.red}}
}

struct StatusText {
    let title:String,detail:String,tone:Tone
}

extension AppModel {
    var gameStatus:StatusText {
        switch game.state {
        case .running where game.hidden:
            return .init(title:L("A játék rejtve","Game hidden"),detail:L("A játék fut, de el van rejtve; a gyűjtéshez látható (akár takart) ablak kell.","The game runs but is hidden; collecting needs a visible (even covered) window."),tone:.warn)
        case .running:
            return .init(title:L("A játék fut","Game running"),detail:L("A játékablak elérhető. Nyugodtan takarhatod más ablakkal.","The game window is available. You may cover it with other windows."),tone:.good)
        case .launching:
            return .init(title:L("Indul…","Launching…"),detail:L("A játék indítását kértem; az ablakára várok.","Launch requested; waiting for its window."),tone:.warn)
        case .windowUnavailable:
            return .init(title:L("Nincs játékablak","No game window"),detail:L("A játék fut, de nincs használható ablaka (kicsinyítve vagy másik Spaces-en?).","The game runs without a usable window (minimised or on another Space?)."),tone:.warn)
        case .notRunning:
            return .init(title:L("A játék nem fut","Game not running"),detail:L("Indítsd el a játékot; a gyűjtő megvárja.","Start the game; the collector waits for it."),tone:.bad)
        case .notInstalled:
            return .init(title:L("Nincs telepítve","Not installed"),detail:L("A Butcher Hero nem található ezen a gépen.","Butcher Hero is not installed on this Mac."),tone:.bad)
        }
    }

    var collectorStatus:StatusText {
        switch collectorState {
        case .stopped:return .init(title:L("Leállítva","Stopped"),detail:L("A gyűjtés ki van kapcsolva.","Collecting is switched off."),tone:.bad)
        case .blocked(let reason):return .init(title:L("Nem tud elindulni","Cannot start"),detail:reason,tone:.bad)
        case .waitingGame:return .init(title:L("A játékra vár","Waiting for the game"),detail:L("A gyűjtő fut, és megvárja, hogy a játék elinduljon.","Collector is on and waits for the game to start."),tone:.warn)
        case .waitingWindow:return .init(title:L("Az ablakra vár","Waiting for the window"),detail:L("A játéknak nincs használható ablaka.","The game has no usable window."),tone:.warn)
        case .starting:return .init(title:L("Indul","Starting"),detail:L("Az első képrögzítésre várok.","Waiting for the first capture."),tone:.warn)
        case .stale(let s):return .init(title:L("Elakadt?","Stalled?"),detail:L("\(s) másodperce nem volt új képrögzítés.","No new capture for \(s) seconds."),tone:.warn)
        case .captureError(let m):return .init(title:L("Képrögzítési hiba","Capture error"),detail:m,tone:.warn)
        case .crystalBlocked:return .init(title:L("Megakadt egy folyamat","A flow is stuck"),detail:L("Egy kristály- vagy eseményablak nem a várt módon viselkedett; kézi beavatkozás kellhet.","A crystal or event screen behaved unexpectedly; it may need you."),tone:.warn)
        case .manualPanel:return .init(title:L("Kézi panel nyitva","Manual panel open"),detail:L("Egy kézzel megnyitott kristálypanel látszik; amíg nyitva van, nem kattintok.","A crystal panel you opened is showing; no clicks while it is open."),tone:.warn)
        case .unrecognized:return .init(title:L("Ismeretlen képernyő","Unknown screen"),detail:L("A játékban nem a megszokott képernyő látszik; várok.","The game shows an unfamiliar screen; waiting."),tone:.warn)
        case .waitingInput:return .init(title:L("Rád vár","Waiting for you"),detail:engine.status.waitReason ?? L("Épp egeret használsz; utána kattintok.","You are using the mouse; clicking afterwards."),tone:.warn)
        case .processing(let t):return .init(title:L("Dolgozik","Working"),detail:t,tone:.good)
        case .running:return .init(title:L("Fut","Running"),detail:L("Felismert játékképernyő; az elérhető Free-jutalmakat a háttérben veszi át.","Game screen recognised; available Free rewards are claimed in the background."),tone:.good)
        }
    }
}
