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
            Text("What You Get with Premium")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.white)

            ForEach([
                ("photo", "Unlimited photo storage", "Add as many memories as you want"),
                ("quote.bubble", "365 unique daily quotes", "Inspirational messages every day of the year"),
                ("calendar", "Complete timeline access", "View and organize all your memories chronologically"),
                ("bell", "Daily memory reminders", "Never miss a moment to remember and reflect"),
                ("heart.circle", "Ad-free experience", "Peaceful, uninterrupted time with your memories"),
                ("star.fill", "Premium support", "Priority customer assistance and feature requests")
            ], id: \.0) { icon, title, description in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 15) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                            .frame(width: 25)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }

    var subscriptionOptionsSection: some View {
        VStack(spacing: 15) {
            Text("Subscription Options")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            if storeManager.products.isEmpty {
                // Fallback options when products fail to load
                VStack(spacing: 15) {
                    subscriptionFallbackCard(
                        title: "Monthly Subscription", 
                        price: "$2.99/month",
                        duration: "Renews every month",
                        features: "All premium features included",
                        productID: "com.remembrance.monthly"
                    )
                    subscriptionFallbackCard(
                        title: "Annual Subscription", 
                        price: "$19.99/year", 
                        duration: "Renews every 12 months",
                        features: "All premium features included • Save 44% vs monthly",
                        badge: "Best Value",
                        productID: "com.remembrance.yearly"
                    )
                }

                Text("Loading subscription options...")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
            } else {
                ForEach(storeManager.products, id: \.id) { product in
                    VStack(spacing: 12) {
                        // Product info card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(product.displayName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)

                                    Text(getSubscriptionDuration(for: product))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 3) {
                                    Text(product.displayPrice)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))

                                    if product.id.contains("yearly") {
                                        Text("Best Value")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            
                            Text(getSubscriptionFeatures(for: product))
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 4)
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
                                    Text("Start 7-Day Free Trial")
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

    private func subscriptionFallbackCard(title: String, price: String, duration: String, features: String, badge: String? = nil, productID: String) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(duration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
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
                
                Text(features)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 4)
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
                        Text("Start 7-Day Free Trial")
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

    var termsSection: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Text("Subscription Details")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text("• Monthly: $2.99/month, renews every month")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("• Annual: $19.99/year, renews every 12 months")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("• 7-day free trial for new subscribers")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("• Cancel anytime in your Apple ID settings")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Payment charged to Apple ID account at confirmation of purchase.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Link("Privacy Policy", destination: URL(string: "https://zumu-g.github.io/Remembrance_app/docs/privacy.html")!)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
                    .underline()

                Link("Terms of Use", destination: URL(string: "https://zumu-g.github.io/Remembrance_app/docs/terms.html")!)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 179/255, green: 154/255, blue: 76/255))
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
    
    private func getSubscriptionDuration(for product: Product) -> String {
        if product.id.contains("monthly") {
            return "Renews every month"
        } else if product.id.contains("yearly") {
            return "Renews every 12 months"
        }
        return "Auto-renewable subscription"
    }
    
    private func getSubscriptionFeatures(for product: Product) -> String {
        if product.id.contains("monthly") {
            return "7-day free trial • All premium features included • Cancel anytime"
        } else if product.id.contains("yearly") {
            return "7-day free trial • All premium features included • Save 44% vs monthly • Cancel anytime"
        }
        return "All premium features included"
    }
}