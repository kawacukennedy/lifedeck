import SwiftUI

struct OnboardingView: View {
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedGoals: [LifeDomainType] = []
    @State private var userName: String = ""
    @State private var isOnboardingComplete = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: DesignSystem.xl) {
                    Spacer()

                    // Progress indicator
                    HStack(spacing: DesignSystem.sm) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            Circle()
                                .fill(step.rawValue <= currentStep.rawValue ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Content
                    VStack(spacing: DesignSystem.lg) {
                        Text(currentStep.title)
                            .font(DesignSystem.h1)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(currentStep.description)
                            .font(DesignSystem.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        stepContent
                    }

                    Spacer()

                    // Navigation buttons
                    HStack(spacing: DesignSystem.md) {
                        if currentStep != .welcome {
                            Button(action: goToPreviousStep) {
                                Text("Back")
                                    .frame(width: 100, height: 56)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(DesignSystem.cornerRadius)
                            }
                        }

                        Spacer()

                        Button(action: goToNextStep) {
                            Text(currentStep == .deckReady ? "Get Started" : "Next")
                                .frame(width: 100, height: 56)
                                .background(Color.primary)
                                .foregroundColor(.white)
                                .cornerRadius(DesignSystem.cornerRadius)
                        }
                        .disabled(!canProceed)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isOnboardingComplete) {
            ContentView()
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .welcome:
            VStack(spacing: DesignSystem.lg) {
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.primary)

                TextField("Enter your name", text: $userName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(DesignSystem.cornerRadius)
                    .foregroundColor(.white)
                    .autocapitalization(.words)
            }
            .frame(width: 300)

        case .goals:
            VStack(spacing: DesignSystem.md) {
                ForEach(LifeDomainType.allCases, id: \.self) { domain in
                    Button(action: { toggleGoal(domain) }) {
                        HStack {
                            Text(domain.rawValue.capitalized)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedGoals.contains(domain) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.primary)
                            } else {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(DesignSystem.cornerRadius)
                    }
                }
            }
            .frame(width: 300)

        case .dataSync:
            VStack(spacing: DesignSystem.lg) {
                Text("Coming Soon")
                    .foregroundColor(.white.opacity(0.6))
                Text("Data integrations will be available in future updates")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

        case .quiz:
            VStack(spacing: DesignSystem.lg) {
                Text("Quick Assessment")
                    .foregroundColor(.white)
                Text("This will help personalize your coaching cards")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

        case .deckReady:
            VStack(spacing: DesignSystem.lg) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.success)

                Text("You're all set!")
                    .foregroundColor(.white)
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case .welcome: return !userName.isEmpty
        case .goals: return !selectedGoals.isEmpty
        default: return true
        }
    }

    private func goToNextStep() {
        if let next = currentStep.nextStep {
            currentStep = next
        } else {
            completeOnboarding()
        }
    }

    private func goToPreviousStep() {
        if let previous = currentStep.previousStep {
            currentStep = previous
        }
    }

    private func toggleGoal(_ domain: LifeDomainType) {
        if selectedGoals.contains(domain) {
            selectedGoals.removeAll { $0 == domain }
        } else {
            selectedGoals.append(domain)
        }
    }

    private func completeOnboarding() {
        let user = User(name: userName, preferences: Preferences(focusAreas: selectedGoals))
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user")
        }
        isOnboardingComplete = true
    }
}