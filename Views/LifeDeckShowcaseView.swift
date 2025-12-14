import SwiftUI

struct LifeDeckShowcaseView: View {
    var body: some View {
        TabView {
            OnboardingView()
                .tabItem {
                    Text("Onboarding")
                }

            ContentView()
                .tabItem {
                    Text("Main App")
                }

            PaywallView()
                .tabItem {
                    Text("Paywall")
                }
        }
    }
}

struct LifeDeckShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        LifeDeckShowcaseView()
    }
}