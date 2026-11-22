import SwiftUI

@main
struct SteganografiaApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .defaultSize(width: 1080, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
