import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = StoreKitManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(red: 51/255, green: 90/255, blue: 76/255)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 25) {
                        trialStatusSection
                        featuresSection
                        subscriptionOptionsSection
                        restorePurchaseButton
                        termsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 20))
                }
                .padding()
                Spacer()
            }

            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

            Text("Remembrance Premium")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("Keep your memories alive")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    var trialStatusSection: some View {
        Group {
            if storeManager.subscriptionStatus == .trial {
                VStack(spacing: 8) {
                    Text("\(storeManager.trialDaysRemaining) days left in trial")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                    Text("Subscribe now to continue using all features")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            } else if storeManager.subscriptionStatus == .expired {
                VStack(spacing: 8) {
                    Text("Your trial has ended")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                    Text("Subscribe to continue cherishing your memories")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    var featuresSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Premium Features")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.white)

            ForEach([
                ("photo", "Unlimited photo storage"),
                ("quote.bubble", "365 daily quotes"),
                ("calendar", "Complete timeline access"),
                ("bell", "Daily memory reminders"),
                ("heart.circle", "Support ongoing development")
            ], id: \.0) { icon, text in
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                        .frame(width: 25)

                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }

    var subscriptionOptionsSection: some View {
        VStack(spacing: 15) {
            if storeManager.products.isEmpty {
                // Fallback options when products fail to load
                VStack(spacing: 15) {
                    subscriptionFallbackCard(title: "Monthly Subscription", price: "$2.99/month", productID: "com.remembrance.monthly")
                    subscriptionFallbackCard(title: "Annual Subscription", price: "$19.99/year", badge: "Save 44%", productID: "com.remembrance.yearly")
                }

                Text("Loading subscription options...")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
            } else {
                ForEach(storeManager.products, id: \.id) { product in
                    VStack(spacing: 12) {
                        // Product info card
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(product.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(product.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(product.displayPrice)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                                if product.id.contains("yearly") {
                                    Text("Save 44%")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedProduct?.id == product.id ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedProduct?.id == product.id ? Color(red: 179/255, green: 154/255, blue: 76/255) : Color.clear, lineWidth: 2)
                        )

                        // Clear Subscribe button
                        Button(action: {
                            selectedProduct = product
                            Task {
                                await purchaseProduct(product)
                            }
                        }) {
                            HStack {
                                Spacer()
                                if isPurchasing && selectedProduct?.id == product.id {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Subscribe Now")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 179/255, green: 154/255, blue: 76/255))
                            .cornerRadius(10)
                        }
                        .disabled(isPurchasing)
                    }
                }
            }
        }
    }

    private func subscriptionFallbackCard(title: String, price: String, badge: String? = nil, productID: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)

            Button(action: {
                Task {
                    await retryPurchase(productID: productID)
                }
            }) {
                HStack {
                    Spacer()
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Subscribe Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(red: 179/255, green: 154/255, blue: 76/255))
                .cornerRadius(10)
            }
            .disabled(isPurchasing)
        }
    }

    var restorePurchaseButton: some View {
        Button(action: {
            Task {
                await restorePurchases()
            }
        }) {
            Text("Restore Purchases")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .underline()
        }
        .disabled(isPurchasing)
    }

    var termsSection: some View {
        VStack(spacing: 10) {
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Link("Privacy Policy", destination: URL(string: "https://remembranceapp.com/privacy")!)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .underline()

                Link("Terms of Service", destination: URL(string: "https://remembranceapp.com/terms")!)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .underline()
            }
        }
        .padding(.top, 10)
    }

    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            _ = try await storeManager.purchase(product)
            dismiss()
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showError = true
        }
    }

    private func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }

        await storeManager.restorePurchases()

        if storeManager.subscriptionStatus == .subscribed {
            dismiss()
        } else {
            errorMessage = "No active subscriptions found"
            showError = true
        }
    }

    private func retryPurchase(productID: String) async {
        isPurchasing = true
        defer { isPurchasing = false }

        // Try to reload products first
        await storeManager.loadProducts()

        // Wait a moment for products to load
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Now try to find the product
        if let product = storeManager.products.first(where: { $0.id == productID }) {
            do {
                _ = try await storeManager.purchase(product)
                dismiss()
            } catch {
                errorMessage = "Purchase failed: \(error.localizedDescription)"
                showError = true
            }
        } else {
            errorMessage = "Unable to load subscription options. Please check your internet connection and try again."
            showError = true
        }
    }
}