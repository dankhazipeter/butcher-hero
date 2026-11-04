import SwiftUI

/// Design tokens: the game's own butcher palette on white paper.
enum Theme {
    static let paper=Color(nsColor:.textBackgroundColor)
    /// The game icon's yellow; the status band while collecting.
    static let butcherYellow=Color(light:"#F6C31B",dark:"#C99A00")
    static let ink=Color(light:"#000000",dark:"#FFFFFF")
    static let blood=Color(light:"#B3122B",dark:"#FF5C6C")
    static let steel=Color(light:"#6E7480",dark:"#9AA0AB")
    static let rule=Color(nsColor:.separatorColor)
    /// Band fill per collector tone: yellow when working, pale when waiting, steel when stopped.
    static func band(_ tone:Tone)->Color {
        switch tone {
        case .good:butcherYellow
        case .warn:Color(light:"#FBE7A1",dark:"#5C4A12")
        case .bad:Color(light:"#E4E6EA",dark:"#2E3036")
        }
    }

    /// Display face: condensed, heavy, poster-like, echoing the game's chunky HUD numerals.
    static func display(_ size:CGFloat)->Font {.custom("Futura-CondensedExtraBold",size:size)}
    static func displayMedium(_ size:CGFloat)->Font {.custom("Futura-CondensedMedium",size:size)}
}
