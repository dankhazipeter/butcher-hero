import Foundation

/// App language, chosen in Settings (default: Hungarian). Strings are kept inline as hu/en pairs.
enum AppLanguage:String,CaseIterable,Identifiable {
    case hu,en
    var id:String {rawValue}
    var name:String {self == .hu ? "Magyar":"English"}
    static let defaultsKey="language"
    static var current:AppLanguage {
        AppLanguage(rawValue:UserDefaults.standard.string(forKey:defaultsKey) ?? "") ?? .hu
    }
    var locale:Locale {Locale(identifier:self == .hu ? "hu_HU":"en_GB")}
}

func L(_ hu:String,_ en:String)->String {AppLanguage.current == .hu ? hu:en}
