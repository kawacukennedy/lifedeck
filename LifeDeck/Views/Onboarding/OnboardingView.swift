import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var user: User
    @State private var currentStep = 0
    
    var body: some View {
        VStack {
            Text("Welcome to LifeDeck")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Your AI-powered personal coach")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
            
            Button("Get Started") {
                user.hasCompletedOnboarding = true
            }
            .buttonStyle(.lifeDeckPrimary())
            .padding()
            
            Spacer()
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
    }
}
