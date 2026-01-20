import SwiftUI
import StoreKit
import Foundation

// Type alias to avoid conflicts
enum AppSubscriptionStatus {
    case notSubscribed, active, expired, cancelled, pendingRenewal, inGracePeriod
    
    var isActive: Bool {
        switch self {
        case .active, .pendingRenewal, .inGracePeriod:
            return true
        case .notSubscribed, .expired, .cancelled:
            return false
        }
    }
}

// MARK: - Subscription Manager
class SubscriptionManager: NSObject, ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isPremium = false
    @Published var subscriptionStatus: AppSubscriptionStatus = .notSubscribed
    private var productIDs: Set<String> = ["com.lifedeck.premium.monthly", "com.lifedeck.premium.yearly"]
    
    override init() {
        super.init()
        loadProducts()
        checkSubscriptionStatus()
    }
    
    func loadProducts() {
        isLoading = true
        Task {
            do {
                if #available(iOS 15.0, *) {
                    self.products = try await Product.products(for: productIDs)
                }
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                print("Failed to load products: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        // For now, default to false - will be implemented with StoreKit 2
        Task {
            if #available(iOS 15.0, *) {
                for await result in Transaction.currentEntitlements {
                    do {
                        let transaction = try checkVerified(result)
                        if transaction.productID.contains("premium") {
                            await MainActor.run {
                                self.isPremium = true
                                self.subscriptionStatus = AppSubscriptionStatus.active
                            }
                            break
                        }
                    } catch {
                        print("Transaction verification failed")
                    }
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func purchase(_ product: Product) async {
        isLoading = true
        do {
            if #available(iOS 15.0, *) {
                let result = try await product.purchase()
                
                switch result {
                case .success(let verification):
                    let transaction = try checkVerified(verification)
                    await transaction.finish()
                    await MainActor.run {
                        self.isPremium = true
                        self.subscriptionStatus = AppSubscriptionStatus.active
                    }
                case .userCancelled:
                    print("User cancelled purchase")
                case .pending:
                    await MainActor.run {
                        self.subscriptionStatus = AppSubscriptionStatus.pendingRenewal
                    }
                @unknown default:
                    break
                }
            }
        } catch {
            print("Purchase failed: \(error)")
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func restorePurchases() {
        isLoading = true
        Task {
            if #available(iOS 15.0, *) {
                for await result in Transaction.currentEntitlements {
                    do {
                        let transaction = try checkVerified(result)
                        if transaction.productID.contains("premium") {
                            await MainActor.run {
                                self.isPremium = true
                                self.subscriptionStatus = AppSubscriptionStatus.active
                            }
                            break
                        }
                    } catch {
                        print("Transaction verification failed")
                    }
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}