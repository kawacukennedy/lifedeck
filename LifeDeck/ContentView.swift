import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        if user.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(User(name: "Test User"))
    }
}