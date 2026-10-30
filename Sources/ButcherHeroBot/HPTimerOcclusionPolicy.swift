import Foundation
enum HPTimerOcclusionPolicy {
    static func matches(_ texts:[String])->Bool {
        texts.contains {raw in
            let s=raw.lowercased()
            if s.contains("m") && (s.contains("s") || s.contains("h")) {return true}
            // A clipped timer can lose its minute marker: "52s16:52K".
            // This is only evidence of occlusion, never a numerical HP reading.
            return s.range(of:"[0-9]{1,2}\\s*s",options:.regularExpression) != nil &&
                s.range(of:"[0-9]+[.,:][0-9]{1,2}\\s*k",options:.regularExpression) != nil
        }
    }
}
