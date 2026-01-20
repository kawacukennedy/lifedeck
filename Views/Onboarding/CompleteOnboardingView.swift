import SwiftUI

// MARK: - Complete Onboarding View
struct CompleteOnboardingView: View {
    @EnvironmentObject var user: CompleteAppUser
    @State private var currentPage = 0
    @State private var selectedDomains: Set<LifeDomainType> = []
    
    private let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to LifeDeck",
            description: "Your personal AI-powered life optimization companion",
            image: "star.circle.fill",
            color: .blue
        ),
        OnboardingStep(
            title: "Daily Coaching Cards",
            description: "Get personalized micro-actions to improve your life",
            image: "rectangle.stack.fill",
            color: .green
        ),
        OnboardingStep(
            title: "Track Your Progress",
            description: "Build habits and see measurable improvements",
            image: "chart.bar.fill",
            color: .orange
        ),
        OnboardingStep(
            title: "Choose Your Focus Areas",
            description: "Select the life domains you want to improve",
            image: "target",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<onboardingSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingSteps.enumerated()), id: \.offset) { index, step in
                    OnboardingStepView(
                        step: step,
                        selectedDomains: $selectedDomains,
                        isLastStep: index == onboardingSteps.count - 1
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                }
                
                Button(currentPage == onboardingSteps.count - 1 ? "Get Started" : "Next") {
                    if currentPage == onboardingSteps.count - 1 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(25)
                .disabled(currentPage == onboardingSteps.count - 1 && selectedDomains.isEmpty)
                .opacity(currentPage == onboardingSteps.count - 1 && selectedDomains.isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
    
    private func completeOnboarding() {
        user.hasCompletedOnboarding = true
        user.settings.focusAreas = Array(selectedDomains)
        
        // Save onboarding completion
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user")
        }
    }
}

// MARK: - Onboarding Step Model
struct OnboardingStep {
    let title: String
    let description: String
    let image: String
    let color: Color
}

// MARK: - Onboarding Step View
struct OnboardingStepView: View {
    let step: OnboardingStep
    @Binding var selectedDomains: Set<LifeDomainType>
    let isLastStep: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: step.image)
                .font(.system(size: 80))
                .foregroundColor(step.color)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.6), value: step.image)
            
            // Text content
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Domain selection for last step
            if isLastStep {
                domainSelectionView
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var domainSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select at least one focus area:")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(LifeDomainType.allCases, id: \.self) { domain in
                    DomainSelectionButton(
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
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Domain Selection Button
struct DomainSelectionButton: View {
    let domain: LifeDomainType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: domain.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : domain.color)
                
                Text(domain.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? domain.color : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(domain.color, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}