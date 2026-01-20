import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var user: User
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedGoals: [String] = []
    
    private let totalSteps = 3
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            progressIndicator
            
            // Content
            TabView(selection: $currentStep) {
                welcomeStep.tag(0)
                nameStep.tag(1)
                preferencesStep.tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            
            // Navigation buttons
            navigationButtons
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .ignoresSafeArea()
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 10) {
            Text("Welcome to LifeDeck")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(.easeInOut, value: currentStep)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Your Personal Life Coach")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get daily AI-powered coaching cards to improve your health, finance, productivity, and mindfulness.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var nameStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("What should we call you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                TextField("Enter your name", text: $userName)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Text("This helps us personalize your experience")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var preferencesStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Almost Done!")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Your personalized deck is ready. Let's start your journey!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut) {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Next/Get Started button
            Button(action: {
                if currentStep < totalSteps - 1 {
                    withAnimation(.easeInOut) {
                        currentStep += 1
                    }
                } else {
                    completeOnboarding()
                }
            }) {
                HStack {
                    if currentStep < totalSteps - 1 {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    } else {
                        Text("Get Started")
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canProceed ? Color.blue : Color.gray)
                .cornerRadius(25)
            }
            .disabled(!canProceed)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2:
            return true
        default:
            return false
        }
    }
    
    private func completeOnboarding() {
        user.name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.hasCompletedOnboarding = true
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(User(name: ""))
    }
}