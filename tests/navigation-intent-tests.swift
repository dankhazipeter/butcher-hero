import Foundation
@main struct Tests {
    static func main() {
        for reason in ["Elakadás észlelve; nyolclépéses tartós akadálykövetés indul",
                       "Tartós akadálykövetés; a felvillanó célok nem szakítják meg a kerülőt",
                       "Célzár: a régi cél irányát tartom", "Minimap alapján: cél",
                       "Tartós akadálytérkép: nyolclépéses falvégi kerülő folytatása"] {
            precondition(NavigationIntentPolicy.owns(reason, targetDistance:165))
        }
        precondition(NavigationIntentPolicy.owns("Legközelebbi HP-csík megközelítése", targetDistance:165))
        precondition(!NavigationIntentPolicy.owns("Legközelebbi HP-csík megközelítése", targetDistance:95))
        for reason in ["Friss sebzésből visszavonulás", "Kontrollált bosspróba indul",
                       "Finom közelítés: az automata támadás még nem zárta le a célpontot",
                       "Kitérős próba"] {
            precondition(!NavigationIntentPolicy.owns(reason, targetDistance:200))
        }
        print("PASS: legacy detours and stale lock routed to V2; contact/combat/retreat preserved")
    }
}
