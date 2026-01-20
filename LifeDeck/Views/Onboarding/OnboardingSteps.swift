import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case goals
    case dataSync
    case quiz
    case deckReady

    var title: String {
        switch self {
        case .welcome: return "Welcome to LifeDeck"
        case .goals: return "Set Your Goals"
        case .dataSync: return "Sync Your Data"
        case .quiz: return "Quick Assessment"
        case .deckReady: return "Your Deck is Ready!"
        }
    }

    var description: String {
        switch self {
        case .welcome: return "AI-powered micro-coaching for a better life"
        case .goals: return "Tell us what areas you'd like to focus on"
        case .dataSync: return "Connect your apps for personalized insights"
        case .quiz: return "Answer a few questions to customize your experience"
        case .deckReady: return "Start your journey with daily coaching cards"
        }
    }

    var nextStep: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previousStep: OnboardingStep? {
        rawValue > 0 ? OnboardingStep(rawValue: rawValue - 1) : nil
    }
}