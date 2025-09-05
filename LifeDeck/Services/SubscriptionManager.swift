import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var subscriptionInfo = SubscriptionInfo()
    @Published var availableProducts: [Product] = []
    @Published var isLoading = false
    @Published var lastError: Error?
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Computed Properties
    var isPremium: Bool {
        subscriptionInfo.isPremium
    }
    
    var featureAccess: FeatureAccess {
        FeatureAccess(subscriptionInfo: subscriptionInfo)
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load saved subscription state
        loadSubscriptionState()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Initialize the subscription manager
    func initialize() async {
        await requestProducts()
        await refreshSubscriptionStatus()
    }
    
    /// Request available products from App Store
    func requestProducts() async {
        isLoading = true
        lastError = nil
        
        do {
            let products = try await Product.products(for: SubscriptionProducts.productIds)
            availableProducts = products.sorted { $0.price < $1.price }
        } catch {
            lastError = error
            print("Failed to request products: \(error)")
        }
        
        isLoading = false
    }
    
    /// Purchase a subscription
    func purchaseSubscription(_ product: Product) async -> Bool {
        isLoading = true
        lastError = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                // Handle successful purchase
                if case .verified(let transaction) = verificationResult {
                    await handleSuccessfulPurchase(transaction)
                    await transaction.finish()
                    return true
                } else {
                    lastError = SubscriptionError.verificationFailed
                    return false
                }
                
            case .userCancelled:
                // User cancelled the purchase
                return false
                
            case .pending:
                // Purchase is pending (e.g., requires parental approval)
                lastError = SubscriptionError.purchasePending
                return false
                
            @unknown default:
                lastError = SubscriptionError.unknownPurchaseResult
                return false
            }
        } catch {
            lastError = error
            print("Purchase failed: \(error)")
            return false
        }
        
        isLoading = false
    }
    
    /// Restore previous purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        lastError = nil
        
        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
            return true
        } catch {
            lastError = error
            print("Failed to restore purchases: \(error)")
            return false
        }
        
        isLoading = false
    }
    
    /// Refresh current subscription status
    func refreshSubscriptionStatus() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await updateSubscriptionStatus(from: transaction)
            }
        }
        
        saveSubscriptionState()
    }
    
    /// Check if user can access a premium feature
    func canAccessFeature(_ feature: PremiumFeature) -> Bool {
        return featureAccess.canAccess(feature)
    }
    
    /// Get the maximum number of daily cards allowed
    var maxDailyCards: Int {
        return featureAccess.maxDailyCards
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.handleTransaction(transaction)
                }
            }
        }
    }
    
    private func handleTransaction(_ transaction: StoreKit.Transaction) async {
        await updateSubscriptionStatus(from: transaction)
        await transaction.finish()
    }
    
    private func handleSuccessfulPurchase(_ transaction: StoreKit.Transaction) async {
        await updateSubscriptionStatus(from: transaction)
        
        // Notify about subscription change
        NotificationCenter.default.post(name: .subscriptionChanged, object: nil)
        
        // Add celebration haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func updateSubscriptionStatus(from transaction: StoreKit.Transaction) async {
        let productId = transaction.productID
        
        // Check if this is a premium subscription
        if SubscriptionProducts.productIds.contains(productId) {
            let newSubscriptionInfo = SubscriptionInfo(
                tier: .premium,
                status: .active
            )
            
            // Update subscription info with transaction details
            subscriptionInfo = SubscriptionInfo(
                tier: .premium,
                status: .active,
                startDate: transaction.purchaseDate,
                expiryDate: transaction.expirationDate,
                autoRenewEnabled: true,
                productId: transaction.productID,
                transactionId: String(transaction.id),
                originalTransactionId: String(transaction.originalID),
                purchaseDate: transaction.purchaseDate
            )
        } else {
            // Reset to free tier if no active subscription
            subscriptionInfo = SubscriptionInfo()
        }
        
        saveSubscriptionState()
    }
    
    private func saveSubscriptionState() {
        if let encoded = try? JSONEncoder().encode(subscriptionInfo) {
            UserDefaults.standard.set(encoded, forKey: "lifedeck_subscription_info")
        }
    }
    
    private func loadSubscriptionState() {
        if let data = UserDefaults.standard.data(forKey: "lifedeck_subscription_info"),
           let decoded = try? JSONDecoder().decode(SubscriptionInfo.self, from: data) {
            subscriptionInfo = decoded
        }
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case verificationFailed
    case purchasePending
    case unknownPurchaseResult
    case productNotFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Unable to verify your purchase. Please try again."
        case .purchasePending:
            return "Your purchase is pending approval. Please check back later."
        case .unknownPurchaseResult:
            return "An unexpected error occurred during purchase."
        case .productNotFound:
            return "The requested subscription is not available."
        case .networkError:
            return "Please check your internet connection and try again."
        }
    }
}

// MARK: - Helper Extensions
extension SubscriptionManager {
    
    /// Get product by ID
    func product(for productId: String) -> Product? {
        return availableProducts.first { $0.id == productId }
    }
    
    /// Get monthly premium product
    var monthlyPremiumProduct: Product? {
        return product(for: SubscriptionProducts.monthlyPremium.id)
    }
    
    /// Get yearly premium product
    var yearlyPremiumProduct: Product? {
        return product(for: SubscriptionProducts.yearlyPremium.id)
    }
    
    /// Check if products are loaded
    var hasLoadedProducts: Bool {
        return !availableProducts.isEmpty
    }
    
    /// Get formatted price for product
    func formattedPrice(for product: Product) -> String {
        return product.displayPrice
    }
    
    /// Get discount percentage for yearly subscription
    var yearlyDiscountPercentage: Int {
        guard let monthly = monthlyPremiumProduct,
              let yearly = yearlyPremiumProduct else {
            return 0
        }
        
        let monthlyYearlyPrice = monthly.price * 12
        let actualYearlyPrice = yearly.price
        let discount = (monthlyYearlyPrice - actualYearlyPrice) / monthlyYearlyPrice
        return Int(truncating: NSDecimalNumber(decimal: discount * 100))
    }
}

// MARK: - Mock Implementation for Previews
#if DEBUG
extension SubscriptionManager {
    static func createMockManager(isPremium: Bool = false) -> SubscriptionManager {
        let manager = SubscriptionManager()
        
        if isPremium {
            manager.subscriptionInfo = SubscriptionInfo(
                tier: .premium,
                status: .active
            )
        }
        
        return manager
    }
}
#endif

// MARK: - StoreKit Extensions
extension Product {
    /// Get the subscription tier for this product
    var subscriptionTier: SubscriptionTier {
        if SubscriptionProducts.productIds.contains(self.id) {
            return .premium
        }
        return .free
    }
    
    /// Get the subscription period
    var subscriptionPeriod: SubscriptionProduct.SubscriptionPeriod? {
        if id == SubscriptionProducts.monthlyPremium.id {
            return .monthly
        } else if id == SubscriptionProducts.yearlyPremium.id {
            return .yearly
        }
        return nil
    }
}

// MARK: - Custom Init for SubscriptionInfo with Transaction Data
extension SubscriptionInfo {
    init(tier: SubscriptionTier, status: SubscriptionStatus, startDate: Date?, expiryDate: Date?, autoRenewEnabled: Bool, productId: String?, transactionId: String?, originalTransactionId: String?, purchaseDate: Date?) {
        self.tier = tier
        self.status = status
        self.startDate = startDate
        self.expiryDate = expiryDate
        self.autoRenewEnabled = autoRenewEnabled
        self.productId = productId
        self.transactionId = transactionId
        self.originalTransactionId = originalTransactionId
        self.purchaseDate = purchaseDate
    }
}
