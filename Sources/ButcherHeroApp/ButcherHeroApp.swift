import AppKit
import SwiftUI

@main struct ButcherHeroApp:App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model=AppModel()
    var body:some Scene {
        Window("Butcher Hero",id:"main") {
            RootView(model:model)
        }
        .defaultSize(width:1100,height:900)
        .commands {
            CommandMenu(L("Gyűjtés","Collecting")) {
                Button(model.collectorEnabled ? L("Gyűjtés leállítása","Stop collecting"):L("Gyűjtés indítása","Start collecting")){model.setCollecting(!model.collectorEnabled)}
                    .keyboardShortcut("r",modifiers:[.command])
                Button(L("Játék indítása","Launch game")){model.game.launch()}
                    .disabled(model.game.state == .running)
            }
        }
        Settings {
            SettingsView(model:model)
        }
    }
}

final class AppDelegate:NSObject,NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification:Notification) {
        // Launched from the Dock the PATH is minimal; the OCR fallback needs Homebrew's tesseract.
        let path=ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin:/bin"
        setenv("PATH","/opt/homebrew/bin:/usr/local/bin:"+path,1)
    }
    /// Closing the window keeps collecting; the Dock icon reopens it.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication)->Bool {false}
}
