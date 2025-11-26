import StoreKit
import Foundation

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var subscriptionStatus: SubscriptionStatus = .unknown
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var trialDaysRemaining: Int = 7

    private var updateListenerTask: Task<Void, Error>?

    enum SubscriptionStatus {
        case unknown
        case trial
        case subscribed
        case expired
        case cancelled
    }

    struct ProductIdentifiers {
        static let monthly = "com.remembrance.monthly"
        static let yearly = "com.remembrance.yearly"
        static let all = [monthly, yearly]
    }

    init() {
        print("🔄 StoreKitManager initializing...")
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateCustomerProductStatus()
            checkTrialStatus()
            print("📱 Initial subscription status: \(subscriptionStatus)")
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        do {
            print("🔄 Attempting to load products for IDs: \(ProductIdentifiers.all)")
            products = try await Product.products(for: ProductIdentifiers.all)
            print("✅ Products loaded: \(products.count) products")
            if products.isEmpty {
                print("⚠️ WARNING: Products array is empty! StoreKit configuration may not be enabled.")
                print("   To fix in Xcode: Edit Scheme → Run → Options → StoreKit Configuration → Select 'Configuration.storekit'")
            }
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await updateCustomerProductStatus()

            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func updateCustomerProductStatus() async {
        var highestProduct: Product?

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        highestProduct = product
                        purchasedProductIDs.insert(transaction.productID)
                    }
                default:
                    break
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        if highestProduct != nil {
            subscriptionStatus = .subscribed
            UserDefaults.standard.set(false, forKey: "isInTrialPeriod")
        } else {
            checkTrialStatus()
        }
    }

    func checkTrialStatus() {
        let trialStartKey = "trialStartDate"
        let isInTrialKey = "isInTrialPeriod"

        if let trialStartDate = UserDefaults.standard.object(forKey: trialStartKey) as? Date {
            let daysSinceStart = Calendar.current.dateComponents([.day], from: trialStartDate, to: Date()).day ?? 0
            let daysRemaining = max(0, 7 - daysSinceStart)

            trialDaysRemaining = daysRemaining

            if daysRemaining > 0 {
                subscriptionStatus = .trial
                UserDefaults.standard.set(true, forKey: isInTrialKey)
            } else {
                subscriptionStatus = .expired
                UserDefaults.standard.set(false, forKey: isInTrialKey)
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: trialStartKey)
            UserDefaults.standard.set(true, forKey: isInTrialKey)
            trialDaysRemaining = 7
            subscriptionStatus = .trial
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            print("Restore purchases failed: \(error)")
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(let transaction, _):
            // Check if we're in sandbox/TestFlight environment
            // This is critical for App Store review
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
               appStoreReceiptURL.lastPathComponent == "sandboxReceipt" {
                print("Detected sandbox environment - allowing unverified transaction")
                // Return the unverified transaction in sandbox
                return transaction
            }
            
            // In debug builds, be more lenient
            #if DEBUG
            print("DEBUG: Allowing unverified transaction in debug mode")
            return transaction
            #else
            // In production, still throw error for security
            throw StoreError.failedVerification
            #endif
            
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    await self.updateCustomerProductStatus()

                    await transaction.finish()
                } catch {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }

    var isSubscribedOrInTrial: Bool {
        subscriptionStatus == .subscribed || subscriptionStatus == .trial
    }

    var needsPaywall: Bool {
        subscriptionStatus == .expired || subscriptionStatus == .cancelled
    }
}

enum StoreError: Error {
    case failedVerification
}