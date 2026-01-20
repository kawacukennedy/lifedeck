import SwiftUI

// MARK: - Life Domain Types (compatible with all views)
enum LifeDomain: String, CaseIterable, Codable {
    case health, finance, productivity, mindfulness
    
    var displayName: String {
        switch self {
        case .health: return "Health"
        case .finance: return "Finance"
        case .productivity: return "Productivity"
        case .mindfulness: return "Mindfulness"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .productivity: return "checkmark.circle.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .finance: return .green
        case .productivity: return .blue
        case .mindfulness: return .purple
        }
    }
}

// MARK: - Basic Models (compatible with all views)
struct SimpleUser: ObservableObject {
    @Published var name: String
    @Published var hasCompletedOnboarding: Bool = false
    
    init(name: String) {
        self.name = name
    }
}

struct SimpleSubscription: Identifiable, Codable {
    let id = UUID()
    let name: String
    let price: String
    
    init(name: String, price: String) {
        self.id = UUID()
        self.name = name
        self.price = price
    }
}

// MARK: - Card Action (compatible with all views)
enum CardAction: String, Codable {
    case complete = "complete"
    case dismiss = "dismiss"
    case snooze = "snooze"
}

// MARK: - Basic Coaching Card (compatible with all views)
struct SimpleCoachingCard: Identifiable, Codable {
    let id = UUID()
    let title: String
    let domain: LifeDomain
    let action: CardAction?
    
    init(
        id: UUID = UUID(),
        title: String,
        domain: LifeDomain,
        action: CardAction? = nil
    ) {
        self.id = id
        self.title = title
        self.domain = domain
        self.action = action
    }
}

// MARK: - Notification Names (compatible with all views)
extension Notification.Name {
    static let showDeck = Notification.Name("showDeck")
    static let showAnalytics = Notification.Name("showAnalytics")
}