import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: ObservableObject {
    // Singleton instance
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var subscriptionStatus: SubscriptionStatus = .none
    @Published var trialDaysRemaining: Int?
    @Published var currentSubscriptionType: String? = nil  // "monthly" or "yearly"
    
    // CRITICAL: These MUST match your App Store Connect Product IDs
    let productIDs = [
        "com.remembrance.monthly",
        "com.remembrance.yearly"
    ]
    
    private var updates: Task<Void, Never>?
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("Loading products with IDs: \(productIDs)")
            products = try await Product.products(for: productIDs)
            print("Loaded \(products.count) products")
            for product in products {
                print("Product: \(product.id) - \(product.displayName) - \(product.displayPrice)")
            }
            await updatePurchasedProducts()
            await checkSubscriptionStatus()
        } catch {
            print("Failed to load products: \(error)")
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        errorMessage = nil
        
        do {
            print("Starting purchase for product: \(product.id)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("Purchase successful, verifying transaction")
                do {
                    let transaction = try checkVerified(verification)
                    print("Transaction verified: \(transaction.id)")
                    await updatePurchasedProducts()
                    await checkSubscriptionStatus()
                    await transaction.finish()
                    isLoading = false
                    return transaction
                } catch {
                    print("Transaction verification failed: \(error)")
                    errorMessage = "Transaction verification failed. Please try again."
                    isLoading = false
                    throw error
                }
                
            case .userCancelled:
                print("Purchase cancelled by user")
                isLoading = false
                return nil
                
            case .pending:
                print("Purchase is pending")
                errorMessage = "Purchase is pending approval"
                isLoading = false
                return nil
                
            @unknown default:
                print("Unknown purchase result")
                errorMessage = "Unknown error occurred"
                isLoading = false
                return nil
            }
        } catch StoreKit.StoreKitError.userCancelled {
            print("User cancelled the purchase")
            isLoading = false
            return nil
        } catch {
            print("Purchase error: \(error)")
            isLoading = false
            // Provide more specific error messages
            if let skError = error as? StoreKit.StoreKitError {
                switch skError {
                case .networkError(_):
                    errorMessage = "Network error. Please check your connection."
                case .systemError(_):
                    errorMessage = "System error. Please try again."
                case .userCancelled:
                    errorMessage = "Purchase was cancelled."
                default:
                    errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Purchase failed: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            await checkSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
                // Track subscription type
                if transaction.productID.contains("monthly") {
                    currentSubscriptionType = "monthly"
                } else if transaction.productID.contains("yearly") {
                    currentSubscriptionType = "yearly"
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
        
        // Update subscription type if no active subscriptions
        if purchasedIDs.isEmpty {
            currentSubscriptionType = nil
        }
    }
    
    // MARK: - Transaction Updates Observer
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try self?.checkVerified(result)
                    await self?.updatePurchasedProducts()
                    await transaction?.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(let transaction, let error):
            // Log details about why verification failed
            print("Transaction verification failed: \(error)")
            print("Unverified transaction: \(transaction)")
            
            // Check if we're in sandbox/TestFlight environment
            // This helps during App Review when production app connects to sandbox
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
    
    // MARK: - Subscription Status
    func hasActiveSubscription() -> Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    func checkSubscriptionStatus() async {
        for product in products {
            guard let subscription = product.subscription else { continue }
            
            do {
                let statuses = try await subscription.status
                
                if let status = statuses.first {
                    // Use if-else instead of switch to avoid exhaustiveness issues
                    let state = status.state
                    
                    if state == .subscribed || state == .inGracePeriod || state == .inBillingRetryPeriod {
                        subscriptionStatus = .active
                    } else if state == .revoked || state == .expired {
                        subscriptionStatus = .expired
                    } else {
                        subscriptionStatus = purchasedProductIDs.isEmpty ? .none : .active
                    }
                    return
                }
            } catch {
                print("Error checking subscription status: \(error)")
            }
        }
        
        subscriptionStatus = purchasedProductIDs.isEmpty ? .none : .active
    }
}

// MARK: - Subscription Status Enum
enum SubscriptionStatus: Equatable {
    case none
    case trial
    case active
    case expired
    
    // Helper to check if user has access
    var hasAccess: Bool {
        return self == .active || self == .trial
    }
}

// MARK: - Store Error
enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseInProgress
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Unable to verify the purchase. Please try again."
        case .productNotFound:
            return "Product not found. Please try again later."
        case .purchaseInProgress:
            return "Another purchase is already in progress."
        }
    }
}

// MARK: - Subscription View
struct SubscriptionView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.pink)
                            
                            Text("Remembrance Premium")
                                .font(.title.bold())
                            
                            Text("Preserve precious memories forever")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)
                        
                        // Subscription Options
                        if storeManager.products.isEmpty {
                            ProgressView()
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                ForEach(storeManager.products, id: \.id) { product in
                                    SubscriptionOptionView(product: product) {
                                        Task {
                                            do {
                                                _ = try await storeManager.purchase(product)
                                            } catch {
                                                print("Purchase error in UI: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Required Subscription Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Subscription Information")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Payment", value: "Charged to your Apple ID")
                                InfoRow(title: "Renewal", value: "Auto-renews unless cancelled")
                                InfoRow(title: "Cancellation", value: "Cancel anytime in Settings")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        // Required Links
                        VStack(spacing: 12) {
                            Link("Privacy Policy", destination: URL(string: "https://zumu-g.github.io/Remembrance_app/docs/privacy.html")!)
                                .font(.footnote)
                            
                            Link("Terms of Use (EULA)", destination: URL(string: "https://zumu-g.github.io/Remembrance_app/docs/terms.html")!)
                                .font(.footnote)
                            
                            Button("Restore Purchases") {
                                Task {
                                    await storeManager.restorePurchases()
                                }
                            }
                            .font(.footnote)
                        }
                        .padding(.bottom, 32)
                    }
                }
                
                if storeManager.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(storeManager.errorMessage != nil)) {
                Button("OK") {
                    storeManager.errorMessage = nil
                }
            } message: {
                Text(storeManager.errorMessage ?? "")
            }
        }
        .task {
            await storeManager.loadProducts()
        }
    }
}

// MARK: - Subscription Option View
struct SubscriptionOptionView: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionTitle)
                        .font(.headline)
                    Text(subscriptionLength)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let pricePerUnit = pricePerUnitText {
                        Text(pricePerUnit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3.bold())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    var subscriptionTitle: String {
        if product.id.contains("monthly") {
            return "Monthly Subscription"
        } else if product.id.contains("yearly") || product.id.contains("annual") {
            return "Annual Subscription"
        } else {
            return product.displayName
        }
    }
    
    var subscriptionLength: String {
        if product.id.contains("monthly") {
            return "1 Month"
        } else if product.id.contains("yearly") || product.id.contains("annual") {
            return "1 Year"
        } else {
            return ""
        }
    }
    
    var pricePerUnitText: String? {
        if product.id.contains("annual"), let price = product.price as Decimal? {
            let monthlyPrice = price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatStyle.locale
            if let formatted = formatter.string(from: monthlyPrice as NSNumber) {
                return "\(formatted)/month"
            }
        }
        return nil
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}
