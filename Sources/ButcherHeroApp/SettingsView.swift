import SwiftUI

struct SettingsView:View {
    @ObservedObject var model:AppModel
    @AppStorage(AppLanguage.defaultsKey) private var language=AppLanguage.hu.rawValue
    @AppStorage(GameMonitor.backgroundPriorityKey) private var gameBackgroundPriority=false
    var body:some View {
        Form {
            Section(L("Általános","General")) {
                Picker(L("Nyelv","Language"),selection:$language) {
                    ForEach(AppLanguage.allCases){Text($0.name).tag($0.rawValue)}
                }
                Toggle(L("Gyűjtés bekapcsolva (indításkor folytatja)","Collecting on (resumes at launch)"),
                       isOn:Binding(get:{model.collectorEnabled},set:{model.setCollecting($0)}))
            }
            Section(L("Játék","Game")) {
                Toggle(L("A játék háttérprioritással fusson","Run the game at background priority"),isOn:$gameBackgroundPriority)
                    .onChange(of:gameBackgroundPriority){model.game.applyPriority()}
                Text(L("A macOS a takarékos magokra teszi a játékot (kevesebb hő és energia); a játék lassabb lehet. Bármikor kikapcsolható.",
                       "macOS moves the game to efficiency cores (less heat and energy); the game may run slower. Can be turned off any time."))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section(L("Engedélyek","Permissions")) {
                PermissionLabel(name:L("Kisegítő lehetőségek","Accessibility"),granted:model.accessibilityGranted)
                PermissionLabel(name:L("Képernyőfelvétel","Screen Recording"),granted:model.screenCaptureGranted)
                HStack {
                    Button(L("Engedélykérés","Request access")){model.requestPermissions()}
                    Button(L("Kisegítő lehetőségek…","Accessibility…")){model.openPrivacySettings("Privacy_Accessibility")}
                    Button(L("Képernyőfelvétel…","Screen Recording…")){model.openPrivacySettings("Privacy_ScreenCapture")}
                }
            }
            Section(L("Adatok","Data")) {
                LabeledContent(L("Hely","Location"),value:AppPaths.root.path)
                LabeledContent(L("Bizonyítékképek","Evidence images"),value:L("1 napig megőrizve","kept for 1 day"))
                Button(L("Megnyitás a Finderben","Show in Finder")){NSWorkspace.shared.open(AppPaths.root)}
            }
        }
        .formStyle(.grouped)
        .frame(width:520)
        .fixedSize(horizontal:false,vertical:true)
        .environment(\.locale,AppLanguage.current.locale)
        .id(language)
    }
}
