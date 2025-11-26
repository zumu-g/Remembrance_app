# Final App Store Submission Checklist

## ✅ Already Fixed
- [x] StoreKit sandbox receipt handling for App Review
- [x] Privacy Policy and Terms URLs updated to GitHub Pages
- [x] Debug code properly isolated with #if DEBUG

## 🔴 MUST DO BEFORE SUBMISSION

### 1. Add Privacy Descriptions in Xcode (5 minutes)
- [ ] Open Xcode project
- [ ] Select Remembrance target → Info tab
- [ ] Add key: `Privacy - Photo Library Usage Description`
  - Value: "Remembrance needs access to your photos to display memories of your loved ones."
- [ ] Add key: `Privacy - Photo Library Additions Usage Description`
  - Value: "Remembrance saves memorial photos to your photo library."

### 2. Create Subscriptions in App Store Connect (30-45 minutes)
- [ ] Log into App Store Connect
- [ ] Navigate to your app → Monetization → In-App Purchases
- [ ] Create Monthly Subscription:
  - Product ID: `com.remembrance.monthly`
  - Price: $2.99
  - Display Name: Monthly Subscription
  - Description: Monthly subscription to Remembrance app
- [ ] Create Yearly Subscription:
  - Product ID: `com.remembrance.yearly`  
  - Price: $19.99
  - Display Name: Annual Subscription
  - Description: Annual subscription to Remembrance app with 44% savings
- [ ] Set up subscription group: "Premium Access"
- [ ] Enable Family Sharing for both

### 3. Verify Live URLs (2 minutes)
- [ ] Check Privacy Policy: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
- [ ] Check Terms of Service: https://zumu-g.github.io/Remembrance_app/docs/terms.html
- [ ] If not live, push to GitHub Pages

### 4. Update Support Email (5 minutes)
- [ ] In SettingsView.swift, update support email from `support@remembranceapp.com` to your actual email
- [ ] Or create a support email address

### 5. Final Build Steps (10 minutes)
- [ ] Clean Build Folder (⇧⌘K)
- [ ] Edit Scheme → Run → Options → StoreKit Configuration → None
- [ ] Select "Any iOS Device" as build target
- [ ] Product → Archive
- [ ] Validate archive
- [ ] Upload to App Store Connect

### 6. In App Store Connect (5 minutes)
- [ ] Update build to the new one
- [ ] Add "What's New" notes: "Fixed in-app purchase issues for App Review"
- [ ] Submit for review

## Response to App Review
When submitting, add this note in the Review Notes:

"We've addressed the in-app purchase issue from the previous review. The app now properly handles sandbox receipts when running in Apple's test environment. The checkVerified() method in StoreKitManager.swift has been updated to detect and allow sandbox transactions during App Review while maintaining security in production."

## Testing Before Submission
- [ ] Build and run in Release mode
- [ ] Verify no debug UI appears
- [ ] Test purchase flow (will fail without real subscriptions, that's OK)
- [ ] Verify privacy policy and terms links work

---
Last Updated: November 23, 2025