import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var user: User
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedFocusAreas: Set<LifeDomain> = []
    @State private var notificationsEnabled = true
    @State private var dailyReminderTime = Date()
    
    private let totalSteps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            progressIndicator
            
            // Content
            TabView(selection: $currentStep) {
                // Step 0: Welcome
                welcomeStep
                    .tag(0)
                
                // Step 1: Name
                nameStep
                    .tag(1)
                
                // Step 2: Focus Areas
                focusAreasStep
                    .tag(2)
                
                // Step 3: Preferences
                preferencesStep
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(DesignSystem.Animation.standard, value: currentStep)
            
            // Navigation buttons
            navigationButtons
        }
        .background(DesignSystem.Gradients.background)
        .ignoresSafeArea()
    }
    
    private var progressIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Welcome to LifeDeck")
                .font(DesignSystem.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, DesignSystem.Spacing.xl)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? .white : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(step == currentStep ? 1.2 : 1.0)
                        .animation(DesignSystem.Animation.quick, value: currentStep)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Your Personal Life Coach")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Get daily AI-powered coaching cards to improve your health, finance, productivity, and mindfulness.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var nameStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("What should we call you?")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                TextField("Enter your name", text: $userName)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.md)
                    .background(.white.opacity(0.2))
                    .cornerRadius(DesignSystem.Spacing.cornerRadius)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, DesignSystem.Spacing.md)
                
                Text("This helps us personalize your experience")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var focusAreasStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Select Your Focus Areas")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Choose the life domains you want to work on:")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                    ForEach(LifeDomain.allCases) { domain in
                        focusAreaButton(domain: domain)
                    }
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private func focusAreaButton(domain: LifeDomain) -> some View {
        Button(action: {
            if selectedFocusAreas.contains(domain) {
                selectedFocusAreas.remove(domain)
            } else {
                selectedFocusAreas.insert(domain)
            }
        }) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: domain.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text(domain.displayName)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(
                selectedFocusAreas.contains(domain) 
                    ? Color.forDomain(domain) 
                    : .white.opacity(0.2)
            )
            .cornerRadius(DesignSystem.Spacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignSystem.Animation.quick, value: selectedFocusAreas)
    }
    
    private var preferencesStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Preferences")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Notifications toggle
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Text("Daily Reminders")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        if notificationsEnabled {
                            Text("Get reminded to complete your daily cards")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Time picker
                    if notificationsEnabled {
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Reminder Time")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    }
                }
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    withAnimation(DesignSystem.Animation.standard) {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            // Next/Skip button
            Button(action: {
                if currentStep < totalSteps - 1 {
                    withAnimation(DesignSystem.Animation.standard) {
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
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    canProceed 
                        ? .white.opacity(0.2) 
                        : .white.opacity(0.1)
                )
                .cornerRadius(DesignSystem.Spacing.cornerRadius)
            }
            .disabled(!canProceed)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2:
            return !selectedFocusAreas.isEmpty
        case 3:
            return true
        default:
            return false
        }
    }
    
    private func completeOnboarding() {
        // Update user data
        user.name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.hasCompletedOnboarding = true
        user.settings.focusAreas = Array(selectedFocusAreas)
        user.settings.notificationsEnabled = notificationsEnabled
        user.settings.dailyReminderTime = dailyReminderTime
        
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(user.settings) {
            UserDefaults.standard.set(data, forKey: "userSettings")
        }
    }
}

// MARK: - Onboarding Steps
struct OnboardingSteps {
    static let steps = [
        OnboardingStep(
            title: "Welcome",
            description: "Your personal AI-powered life coach",
            icon: "heart.circle.fill"
        ),
        OnboardingStep(
            title: "Personalize",
            description: "Tell us about yourself",
            icon: "person.circle.fill"
        ),
        OnboardingStep(
            title: "Focus Areas",
            description: "Choose what matters to you",
            icon: "target"
        ),
        OnboardingStep(
            title: "Preferences",
            description: "Set up your experience",
            icon: "gearshape.fill"
        )
    ]
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
}