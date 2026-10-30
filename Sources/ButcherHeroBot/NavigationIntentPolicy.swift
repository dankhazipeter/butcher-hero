import Foundation

/// Legacy strategy produces movement suggestions; V2 owns navigation execution.
/// Combat, retreat and final contact are intentionally not navigation requests.
enum NavigationIntentPolicy {
    static func owns(_ reason: String, targetDistance: Double?) -> Bool {
        if reason.hasPrefix("Legközelebbi HP-csík megközelítése") ||
           reason.hasPrefix("A cél ideiglenesen eltűnt") {
            return (targetDistance ?? .infinity) > 110
        }
        return [
            "Minimap alapján", "Minimap-útvonal", "Nincs látható cél",
            "Tartós akadálytérkép:", "A falmenti kerülőt tartom",
            "Hat végrehajtott swipe", "Hűtőlistás lezárt", "Island 2 ",
            "Titan→Deep Mines mért gráfél:", "Tartós térkép:", "Térképi farmcél:",
            "Ismételten elérhetetlen célterület", "A kimerített magaslati ládaág",
            "Elakadás észlelve;", "Tartós akadálykövetés;", "Célzár:",
            "A célterület két kerülő után", "A 499 HP-s hordozó kerítése",
            "A hordozó kerítését kívülről", "Nem értékelhető cél",
            "A látható türkiz Deep Mines küldetésútvonal követése"
        ].contains { reason.hasPrefix($0) }
    }
}
