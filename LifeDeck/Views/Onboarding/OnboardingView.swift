import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var user: User
    @State private var currentStep = 0
    @State private var selectedDomains: Set<LifeDomain> = []
    @State private var userName = ""
    @State private var showLoadingAnimation = false
    
    private let totalSteps = 5
    
    var body: some View {
        ZStack {
            Color.lifeDeckBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Content area
                TabView(selection: $currentStep) {
                    // Step 1: Welcome
                    WelcomeStep()
                        .tag(0)
                    
                    // Step 2: Goal Selection
                    GoalSelectionStep(selectedDomains: $selectedDomains)
                        .tag(1)
                    
                    // Step 3: Data Sync (Optional)
                    DataSyncStep()
                        .tag(2)
                    
                    // Step 4: Personalization
                    PersonalizationStep(userName: $userName)
                        .tag(3)
                    
                    // Step 5: Deck Ready
                    DeckReadyStep(showLoadingAnimation: $showLoadingAnimation)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.lifeDeckSecondary)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "Start Your Journey" : "Continue") {
                        if currentStep == totalSteps - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(currentStep == totalSteps - 1 ? LifeDeckPremiumButtonStyle() : LifeDeckPrimaryButtonStyle())
                    .disabled(currentStep == 1 && selectedDomains.isEmpty)
                }
                .padding()
            }
        }
    }
    
    private func completeOnboarding() {
        // Save selected domains
        for domain in selectedDomains {
            let goal = UserGoal(
                domain: domain,
                description: "Improve my \(domain.displayName.lowercased())",
                targetValue: 100,
                currentValue: 0
            )
            user.addGoal(goal)
        }
        
        // Save user name
        if !userName.isEmpty {
            user.name = userName
        }
        
        // Complete onboarding
        user.hasCompletedOnboarding = true
    }
}

// MARK: - Onboarding Step Components

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? Color.lifeDeckPrimary : Color.lifeDeckCardBorder)
                    .frame(height: 6)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo animation area
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.lifeDeckPrimary.opacity(0.3),
                                Color.lifeDeckSecondary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.lifeDeckPrimary,
                                Color.lifeDeckSecondary
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 16) {
                Text("Your AI Micro-Coach Awaits")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Small daily steps. Big life change.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct GoalSelectionStep: View {
    @Binding var selectedDomains: Set<LifeDomain>
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Choose Your Focus Areas")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Select the life domains you want to improve. You can always change these later.")
                    .font(.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(LifeDomain.allCases) { domain in
                    DomainSelectionCard(
                        domain: domain,
                        isSelected: selectedDomains.contains(domain)
                    ) {
                        if selectedDomains.contains(domain) {
                            selectedDomains.remove(domain)
                        } else {
                            selectedDomains.insert(domain)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            if !selectedDomains.isEmpty {
                Text("Selected: \(selectedDomains.count) domain\(selectedDomains.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.lifeDeckSuccess)
            }
        }
    }
}

struct DomainSelectionCard: View {
    let domain: LifeDomain
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: domain.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .lifeDeckTextPrimary : Color.forDomain(domain))
                
                VStack(spacing: 4) {
                    Text(domain.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text(domainDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.lifeDeckTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.lifeDeckPrimary.opacity(0.1) : Color.lifeDeckCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.lifeDeckPrimary : Color.lifeDeckCardBorder,
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var domainDescription: String {
        switch domain {
        case .health: return "Physical wellness"
        case .finance: return "Money management"
        case .productivity: return "Getting things done"
        case .mindfulness: return "Mental wellness"
        }
    }
}

struct DataSyncStep: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Connect Your Data")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Optional: Connect your apps for more personalized coaching.")
                    .font(.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                IntegrationButton(
                    title: "Connect Apple Health",
                    subtitle: "Track fitness and health metrics",
                    icon: "heart.fill",
                    color: .lifeDeckHealth
                )
                
                IntegrationButton(
                    title: "Connect Calendar",
                    subtitle: "Schedule coaching at optimal times",
                    icon: "calendar",
                    color: .lifeDeckProductivity
                )
                
                IntegrationButton(
                    title: "Connect Bank (Plaid)",
                    subtitle: "Get personalized finance coaching",
                    icon: "creditcard.fill",
                    color: .lifeDeckFinance
                )
            }
            .padding(.horizontal)
            
            Button("Skip for now") {
                // Skip data sync
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.lifeDeckTextSecondary)
        }
    }
}

struct IntegrationButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button {
            // Handle integration
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.lifeDeckTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.lifeDeckTextTertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.lifeDeckCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.lifeDeckCardBorder, lineWidth: 1)
                    )
            )
        }
    }
}

struct PersonalizationStep: View {
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Tell Us About Yourself")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Help us personalize your coaching experience.")
                    .font(.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    TextField("Enter your name", text: $userName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.lifeDeckCardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.lifeDeckCardBorder, lineWidth: 1)
                                )
                        )
                        .foregroundColor(.lifeDeckTextPrimary)
                }
                
                // Additional personalization options could go here
                VStack(alignment: .leading, spacing: 12) {
                    Text("When are you most motivated?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    HStack {
                        PersonalizationPill(title: "Morning", isSelected: true)
                        PersonalizationPill(title: "Afternoon", isSelected: false)
                        PersonalizationPill(title: "Evening", isSelected: false)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct PersonalizationPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .lifeDeckTextPrimary : .lifeDeckTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.lifeDeckPrimary.opacity(0.2) : Color.lifeDeckCardBackground)
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? Color.lifeDeckPrimary : Color.lifeDeckCardBorder,
                                lineWidth: 1
                            )
                    )
            )
    }
}

struct DeckReadyStep: View {
    @Binding var showLoadingAnimation: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Deck shuffling animation
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.lifeDeckPrimary.opacity(0.8),
                                    Color.lifeDeckSecondary.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 280)
                        .offset(
                            x: showLoadingAnimation ? CGFloat(index * 5) : CGFloat(index * 15),
                            y: showLoadingAnimation ? CGFloat(index * -5) : CGFloat(index * -10)
                        )
                        .rotationEffect(
                            .degrees(showLoadingAnimation ? Double(index * 2) : Double(index * 5))
                        )
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: showLoadingAnimation
                        )
                }
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.lifeDeckSuccess)
                    .scaleEffect(showLoadingAnimation ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: showLoadingAnimation
                    )
            }
            
            VStack(spacing: 16) {
                Text("Your personalized LifeDeck is ready!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We've created a custom deck of micro-coaching cards just for you. Ready to transform your daily routine?")
                    .font(.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            showLoadingAnimation = true
        }
    }
}
