import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var subscription: Subscription = Subscription(tier: .free, isActive: false)
    
    func purchase() async {
        // Implementation would go here
        print("Purchase flow would be implemented")
    }
    
    func isPremium() -> Bool {
        return subscription.isPremium
    }
}