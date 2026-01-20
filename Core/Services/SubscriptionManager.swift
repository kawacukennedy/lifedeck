import Foundation
import StoreKit
import SwiftUI

// MARK: - Subscription Manager
class SubscriptionManager: NSObject, ObservableObject {
    @Published var isPremium: Bool = false
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    @Published var isLoading: Bool = false
    @Published var products: [Product] = []
    @Published var subscriptionInfo: AppSubscriptionInfo = AppSubscriptionInfo()
    
    private let productIdentifiers = Set([
        "com.lifedeck.premium.monthly",
        "com.lifedeck.premium.yearly",
        "com.lifedeck.premium.lifetime"
    ])
    
    private var updateListenerTask: Task<Void, Error>?
    
    override init() {
        super.init()
        loadProducts()
        checkSubscriptionStatus()
        setupStoreKitListener()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() {
        Task {
            do {
                let products = try await Product.products(for: productIdentifiers)
                await MainActor.run {
                    self.products = products
                }
            } catch {
                print("Failed to load products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Purchase Methods
    func purchase(_ product: Product) async throws -> Product.PurchaseResult {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await processSuccessfulPurchase(transaction)
            await transaction.finish()
            return .success(verification)
            
        case .userCancelled:
            return .userCancelled
            
        case .pending:
            return .pending
            
        @unknown default:
            return .userCancelled
        }
    }
    
    func restorePurchases() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await AppStore.sync()
                await checkCurrentEntitlements()
            } catch {
                print("Failed to restore purchases: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Subscription Status
    private func checkSubscriptionStatus() {
        Task {
            await checkCurrentEntitlements()
        }
    }
    
    @MainActor
    private func checkCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID.contains("premium") && transaction.revocationDate == nil {
                    updateSubscriptionStatus(to: .active, transaction: transaction)
                    return
                }
            } catch {
                print("Transaction verification failed: \(error.localizedDescription)")
            }
        }
        
        // Check local receipt as fallback
        if UserDefaults.standard.bool(forKey: "isPremium") {
            updateSubscriptionStatus(to: .active)
        } else {
            updateSubscriptionStatus(to: .notSubscribed)
        }
    }
    
    private func setupStoreKitListener() {
        updateListenerTask = Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.processSuccessfulPurchase(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func processSuccessfulPurchase(_ transaction: Transaction) async {
        if transaction.productID.contains("premium") {
            updateSubscriptionStatus(to: .active, transaction: transaction)
            UserDefaults.standard.set(true, forKey: "isPremium")
        }
    }
    
    @MainActor
    private func updateSubscriptionStatus(to status: SubscriptionStatus, transaction: Transaction? = nil) {
        subscriptionStatus = status
        isPremium = status.isActive
        
        if let transaction = transaction {
            subscriptionInfo = AppSubscriptionInfo(
                tier: .premium,
                status: status,
                startDate: transaction.purchaseDate,
                expiryDate: transaction.expirationDate,
                autoRenewEnabled: transaction.upgradedTransactionID != nil,
                productId: transaction.productID,
                transactionId: transaction.id.uuidString,
                originalTransactionId: transaction.originalID?.uuidString,
                purchaseDate: transaction.purchaseDate
            )
        }
    }
    
    // MARK: - Feature Checks
    func canAccessPremiumFeatures() -> Bool {
        return isPremium
    }
    
    func hasUnlimitedCards() -> Bool {
        return isPremium
    }
    
    func getDailyCardLimit() -> Int {
        return isPremium ? 999 : 5
    }
    
    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Subscription Error
enum SubscriptionError: LocalizedError {
    case verificationFailed
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Purchase verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

// MARK: - Product Extensions
extension Product {
    var localizedPrice: String {
        price.formatted(.currency(code: priceFormatStyle.currencyCode))
    }
    
    private var priceFormatStyle: FloatingPointFormatStyle<Double>.Currency {
        .currency(code: Locale.current.currency?.identifier ?? "USD")
    }
    
    var subscriptionPeriod: String? {
        switch self.type {
        case .autoRenewable:
            if let subscription = self.subscription {
                switch subscription.subscriptionPeriod {
                case .oneMonth:
                    return "Monthly"
                case .oneYear:
                    return "Yearly"
                default:
                    return subscription.subscriptionPeriod.description
                }
            }
        case .nonConsumable:
            return "Lifetime"
        default:
            return nil
        }
    }
}