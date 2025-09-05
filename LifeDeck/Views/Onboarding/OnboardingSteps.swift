import SwiftUI

struct OnboardingSteps: View {
    var body: some View {
        VStack {
            Text("Onboarding Steps")
                .font(.title)
                .padding()
            
            Text("This will contain the multi-step onboarding process")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}
