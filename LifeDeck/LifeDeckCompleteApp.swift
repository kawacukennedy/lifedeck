import SwiftUI

@main
struct LifeDeckCompleteApp: App {
    @StateObject private var user = User(name: "")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(user)
        }
    }
}