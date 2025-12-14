import Foundation

enum SubscriptionTier: String, Codable {
    case free
    case premium
}

struct Subscription: Codable {
    var tier: SubscriptionTier
    var isActive: Bool
    var expirationDate: Date?
    var features: [SubscriptionFeature]

    init(tier: SubscriptionTier = .free, isActive: Bool = true, expirationDate: Date? = nil) {
        self.tier = tier
        self.isActive = isActive
        self.expirationDate = expirationDate
        self.features = tier == .free ? Subscription.freeFeatures : Subscription.premiumFeatures
    }

    static let freeFeatures: [SubscriptionFeature] = [
        .dailyCards(5),
        .basicAnalytics,
        .streaks,
        .lifePoints
    ]

    static let premiumFeatures: [SubscriptionFeature] = [
        .unlimitedCards,
        .advancedAnalytics,
        .dataIntegrations,
        .customRituals,
        .exclusiveRewards,
        .aiPersonalization,
        .crossDomainInsights
    ]

    func hasFeature(_ feature: SubscriptionFeature) -> Bool {
        return features.contains(feature)
    }
}

enum SubscriptionFeature: Equatable, Codable {
    case dailyCards(Int)
    case unlimitedCards
    case basicAnalytics
    case advancedAnalytics
    case dataIntegrations
    case customRituals
    case exclusiveRewards
    case aiPersonalization
    case crossDomainInsights
    case streaks
    case lifePoints
}