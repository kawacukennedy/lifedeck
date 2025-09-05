import Foundation
import StoreKit

// MARK: - Subscription Tier
enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "free"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .free: return "$0"
        case .premium: return "$7.99"
        }
    }
    
    var yearlyPrice: String {
        switch self {
        case .free: return "$0"
        case .premium: return "$79.99" // 17% discount
        }
    }
}

// MARK: - Premium Features
enum PremiumFeature: String, CaseIterable, Codable {
    case unlimitedCards = "unlimited_cards"
    case advancedAnalytics = "advanced_analytics"
    case dataIntegrations = "data_integrations"
    case customRituals = "custom_rituals"
    case prioritySupport = "priority_support"
    case exclusiveRewards = "exclusive_rewards"
    case aiPersonalization = "ai_personalization"
    case crossDomainInsights = "cross_domain_insights"
    
    var displayName: String {
        switch self {
        case .unlimitedCards: return "Unlimited Daily Cards"
        case .advancedAnalytics: return "Advanced Analytics"
        case .dataIntegrations: return "Data Integrations"
        case .customRituals: return "Custom Daily Rituals"
        case .prioritySupport: return "Priority Support"
        case .exclusiveRewards: return "Exclusive Rewards"
        case .aiPersonalization: return "Advanced AI Personalization"
        case .crossDomainInsights: return "Cross-Domain Insights"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedCards: return "Get more than 5 coaching cards per day"
        case .advancedAnalytics: return "Deep insights and Life Score trends"
        case .dataIntegrations: return "Apple Health, Google Fit, Plaid, Calendar"
        case .customRituals: return "Create personalized daily wellness routines"
        case .prioritySupport: return "Faster customer service via chat or email"
        case .exclusiveRewards: return "Special badges and gamification perks"
        case .aiPersonalization: return "Smarter recommendations based on your habits"
        case .crossDomainInsights: return "See how different life areas affect each other"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedCards: return "infinity.circle.fill"
        case .advancedAnalytics: return "chart.xyaxis.line"
        case .dataIntegrations: return "link.circle.fill"
        case .customRituals: return "star.square.fill"
        case .prioritySupport: return "message.badge.fill"
        case .exclusiveRewards: return "crown.fill"
        case .aiPersonalization: return "brain.head.profile"
        case .crossDomainInsights: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - Subscription Product
struct SubscriptionProduct: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let price: String
    let period: SubscriptionPeriod
    let tier: SubscriptionTier
    
    enum SubscriptionPeriod: String, CaseIterable {
        case monthly = "monthly"
        case yearly = "yearly"
        
        var displayName: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: String, CaseIterable, Codable {
    case notSubscribed = "not_subscribed"
    case active = "active"
    case expired = "expired"
    case cancelled = "cancelled"
    case pendingRenewal = "pending_renewal"
    case inGracePeriod = "in_grace_period"
    
    var displayName: String {
        switch self {
        case .notSubscribed: return "Free"
        case .active: return "Active Premium"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        case .pendingRenewal: return "Pending Renewal"
        case .inGracePeriod: return "Grace Period"
        }
    }
}

// MARK: - Subscription Information
struct SubscriptionInfo: Codable {
    let tier: SubscriptionTier
    let status: SubscriptionStatus
    let startDate: Date?
    let expiryDate: Date?
    let autoRenewEnabled: Bool
    let productId: String?
    let transactionId: String?
    let originalTransactionId: String?
    let purchaseDate: Date?
    
    init(tier: SubscriptionTier = .free, status: SubscriptionStatus = .notSubscribed) {
        self.tier = tier
        self.status = status
        self.startDate = nil
        self.expiryDate = nil
        self.autoRenewEnabled = false
        self.productId = nil
        self.transactionId = nil
        self.originalTransactionId = nil
        self.purchaseDate = nil
    }
    
    var isActive: Bool {
        switch status {
        case .active, .pendingRenewal, .inGracePeriod:
            return true
        case .notSubscribed, .expired, .cancelled:
            return false
        }
    }
    
    var isPremium: Bool {
        return tier == .premium && isActive
    }
    
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day
    }
}

// MARK: - Feature Access Control
struct FeatureAccess {
    let subscriptionInfo: SubscriptionInfo
    
    func canAccess(_ feature: PremiumFeature) -> Bool {
        return subscriptionInfo.isPremium
    }
    
    var maxDailyCards: Int {
        return subscriptionInfo.isPremium ? 50 : 5
    }
    
    var hasAdvancedAnalytics: Bool {
        return canAccess(.advancedAnalytics)
    }
    
    var hasDataIntegrations: Bool {
        return canAccess(.dataIntegrations)
    }
    
    var hasCustomRituals: Bool {
        return canAccess(.customRituals)
    }
    
    var hasPrioritySupport: Bool {
        return canAccess(.prioritySupport)
    }
    
    var hasExclusiveRewards: Bool {
        return canAccess(.exclusiveRewards)
    }
    
    var hasAdvancedAI: Bool {
        return canAccess(.aiPersonalization)
    }
    
    var hasCrossDomainInsights: Bool {
        return canAccess(.crossDomainInsights)
    }
}

// MARK: - Subscription Comparison
struct SubscriptionComparison {
    struct Feature {
        let name: String
        let description: String
        let icon: String
        let freeIncluded: Bool
        let premiumIncluded: Bool
        
        init(name: String, description: String, icon: String, freeIncluded: Bool, premiumIncluded: Bool = true) {
            self.name = name
            self.description = description
            self.icon = icon
            self.freeIncluded = freeIncluded
            self.premiumIncluded = premiumIncluded
        }
    }
    
    static let features: [Feature] = [
        Feature(name: "Daily Coaching Cards", description: "Up to 5 per day", icon: "rectangle.stack.fill", freeIncluded: true),
        Feature(name: "Unlimited Cards", description: "No daily limits", icon: "infinity.circle.fill", freeIncluded: false),
        Feature(name: "Basic Progress Tracking", description: "Simple charts and streaks", icon: "chart.bar.fill", freeIncluded: true),
        Feature(name: "Advanced Analytics", description: "Deep insights and trends", icon: "chart.xyaxis.line", freeIncluded: false),
        Feature(name: "Streak Building", description: "Track daily consistency", icon: "flame.fill", freeIncluded: true),
        Feature(name: "Life Points & Achievements", description: "Gamification elements", icon: "star.circle.fill", freeIncluded: true),
        Feature(name: "Data Integrations", description: "Apple Health, Plaid, Calendar", icon: "link.circle.fill", freeIncluded: false),
        Feature(name: "Custom Rituals", description: "Personalized routines", icon: "star.square.fill", freeIncluded: false),
        Feature(name: "Cross-Domain Insights", description: "How life areas affect each other", icon: "arrow.triangle.2.circlepath", freeIncluded: false),
        Feature(name: "Advanced AI", description: "Smarter personalization", icon: "brain.head.profile", freeIncluded: false),
        Feature(name: "Priority Support", description: "Faster customer service", icon: "message.badge.fill", freeIncluded: false),
        Feature(name: "Exclusive Rewards", description: "Special badges and perks", icon: "crown.fill", freeIncluded: false)
    ]
    
    static var freeFeatures: [Feature] {
        return features.filter { $0.freeIncluded }
    }
    
    static var premiumOnlyFeatures: [Feature] {
        return features.filter { !$0.freeIncluded }
    }
}

// MARK: - Subscription Products Configuration
struct SubscriptionProducts {
    static let monthlyPremium = SubscriptionProduct(
        id: "com.lifedeck.premium.monthly",
        displayName: "Premium Monthly",
        description: "All premium features, billed monthly",
        price: "$7.99",
        period: .monthly,
        tier: .premium
    )
    
    static let yearlyPremium = SubscriptionProduct(
        id: "com.lifedeck.premium.yearly", 
        displayName: "Premium Yearly",
        description: "All premium features, billed yearly (17% off)",
        price: "$79.99",
        period: .yearly,
        tier: .premium
    )
    
    static let allProducts: [SubscriptionProduct] = [
        monthlyPremium,
        yearlyPremium
    ]
    
    static let productIds: [String] = allProducts.map { $0.id }
}

// MARK: - Trial Information
struct TrialInfo: Codable {
    let isEligible: Bool
    let duration: Int // days
    let hasUsedTrial: Bool
    let trialStartDate: Date?
    let trialEndDate: Date?
    
    init() {
        self.isEligible = true
        self.duration = 7
        self.hasUsedTrial = false
        self.trialStartDate = nil
        self.trialEndDate = nil
    }
    
    var isInTrial: Bool {
        guard let endDate = trialEndDate else { return false }
        return Date() <= endDate
    }
    
    var trialDaysRemaining: Int {
        guard let endDate = trialEndDate, isInTrial else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }
}
