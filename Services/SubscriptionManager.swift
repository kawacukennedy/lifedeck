import Foundation
import StoreKit

class SubscriptionManager: ObservableObject {
    @Published var subscription: Subscription = .init()

    private var product: Product?
    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await requestProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func requestProducts() async {
        do {
            let productIdentifiers = ["com.lifedeck.premium.monthly"]
            let products = try await Product.products(for: productIdentifiers)
            self.product = products.first
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase() async throws {
        guard let product = product else { return }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            updateSubscriptionStatus()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        updateSubscriptionStatus()
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await MainActor.run {
                        self.updateSubscriptionStatus()
                    }
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updateSubscriptionStatus() {
        Task {
            let entitlements = await Transaction.currentEntitlements
            var hasActiveSubscription = false

            for await result in entitlements {
                do {
                    let transaction = try checkVerified(result)
                    if transaction.productID == "com.lifedeck.premium.monthly" {
                        hasActiveSubscription = true
                        break
                    }
                } catch {
                    print("Failed to verify entitlement: \(error)")
                }
            }

            await MainActor.run {
                self.subscription = Subscription(tier: hasActiveSubscription ? .premium : .free, isActive: hasActiveSubscription)
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}