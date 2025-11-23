import SwiftUI

struct PurchaseSuccessView: View {
    @Environment(\.dismiss) var dismiss
    let subscriptionType: String
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 51/255, green: 90/255, blue: 76/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .padding(.top, 50)
                
                // Title
                Text("You're All Set!")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                // Subscription Info
                VStack(spacing: 10) {
                    Text("Welcome to Premium")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(subscriptionType == "monthly" ? "Monthly Subscription Active" : "Annual Subscription Active")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 179/255, green: 154/255, blue: 76/255))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}