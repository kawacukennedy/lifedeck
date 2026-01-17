import Foundation
import StoreKit

class SubscriptionManager: ObservableObject {
    @Published var subscription = Subscription(tier: .free, isActive: false)
    
    func purchase() async {
        // Simplified for now
        print("Purchase would go here")
    }
    
    func isPremium() -> Bool {
        return subscription.isPremium
    }
}