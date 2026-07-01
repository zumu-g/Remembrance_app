# App Store Launch Checklist - Remembrance App

## Target Launch: Tomorrow

---

## 🔴 CRITICAL - Must Complete Today

### 1. App Store Connect - Subscription Products Setup
**Time Required:** 30-45 minutes
**Status:** ⚠️ PENDING

#### Steps:
1. **Go to App Store Connect:** https://appstoreconnect.apple.com
2. Navigate to: **My Apps** → **Remembrance** → **Subscriptions**
3. Click **"+"** to create Subscription Group
   - Name: "Premium Access"
4. **Add Monthly Subscription:**
   - Product ID: `com.remembrance.monthly`
   - Reference Name: "Monthly Subscription"
   - Subscription Duration: 1 Month
   - Price: $2.99 (Tier 3)
   - Free Trial: 7 Days
   - Localization (English US):
     - Display Name: "Monthly Subscription"
     - Description: "Monthly subscription to Remembrance app"
5. **Add Annual Subscription:**
   - Product ID: `com.remembrance.yearly`
   - Reference Name: "Annual Subscription"
   - Subscription Duration: 1 Year
   - Price: $19.99 (Tier 20)
   - Free Trial: 7 Days
   - Localization (English US):
     - Display Name: "Annual Subscription"
     - Description: "Annual subscription to Remembrance app with 44% savings"
6. **Submit subscriptions for review** (can be done with app submission)

**IMPORTANT:** Product IDs MUST match exactly:
- ✅ `com.remembrance.monthly`
- ✅ `com.remembrance.yearly`

### 2. Privacy Policy & Terms of Service URLs
**Status:** ⚠️ PENDING

Currently hardcoded URLs:
- Privacy Policy: `https://remembranceapp.com/privacy`
- Terms of Service: `https://remembranceapp.com/terms`

**Options:**
A) Host these files on your domain (remembranceapp.com)
B) Use existing files (privacy-policy.html, terms-of-service.html) and host them
C) Use GitHub Pages (free hosting)

**Files exist locally:**
- ✅ privacy-policy.html
- ✅ terms-of-service.html

**Action needed:** Upload to web server

### 3. Bundle ID & App Store Connect App
**Status:** ⚠️ NEEDS VERIFICATION

Current Bundle ID: `stuartgrant.Remembrance`

**Verify:**
- App exists in App Store Connect
- Bundle ID matches Xcode project
- Certificates/provisioning profiles are valid

### 4. App Review Information
**Required for App Store submission:**
- Demo account (if applicable)
- Contact information
- Notes for reviewer about memorial/grief nature of app

---

## ✅ COMPLETED - Already Done

### Code & Features
- ✅ Settings page with quotes toggle
- ✅ Subscription UI (PaywallView with Subscribe buttons)
- ✅ StoreKit integration code
- ✅ Trial period logic (7 days)
- ✅ Restore purchases in Settings
- ✅ Error handling for failed purchases
- ✅ Privacy policy & terms links in UI

### Files & Configuration
- ✅ Configuration.storekit (local testing config)
- ✅ Product IDs defined in code
- ✅ StoreKitManager implemented
- ✅ .gitignore for build artifacts
- ✅ Git repository up to date

---

## 📋 Pre-Submission Checklist

### Build & Archive
- [ ] Set to Release configuration
- [ ] Increment version/build number
- [ ] Archive app (Product → Archive)
- [ ] Validate archive
- [ ] Upload to App Store Connect

### App Store Connect Metadata
- [ ] App name: "Remembrance"
- [ ] Subtitle/promotional text
- [ ] Description
- [ ] Keywords
- [ ] Screenshots (all required sizes)
- [ ] App icon (1024x1024 - already have)
- [ ] Privacy policy URL (must be live)
- [ ] Terms of service URL (must be live)
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] Age rating (likely 4+)
- [ ] App category (Lifestyle or Health & Fitness)

### Subscriptions in App Store Connect
- [ ] Monthly subscription created ($2.99)
- [ ] Annual subscription created ($19.99)
- [ ] Free trial configured (7 days)
- [ ] Localizations added
- [ ] Screenshot/promotional content (optional)

### Testing Before Submission
- [ ] Test in Simulator with StoreKit Configuration
- [ ] Test on real device with TestFlight (recommended)
- [ ] Verify subscription purchase flow
- [ ] Verify restore purchases works
- [ ] Test trial period countdown
- [ ] Check all UI screens

### Legal/Compliance
- [ ] Privacy policy live and accessible
- [ ] Terms of service live and accessible
- [ ] Age rating appropriate
- [ ] No restricted content issues

---

## 🚀 Tomorrow's Launch Steps

### Morning:
1. Final testing on TestFlight
2. Submit for App Review
3. Set release to "Manual" (you control when it goes live)

### When Approved:
4. Release to App Store
5. Monitor for crashes/issues
6. Respond to user reviews

---

## ⚡ Quick Actions Needed NOW

### Priority 1: App Store Connect Subscriptions
**DO THIS FIRST** - Cannot launch without this
1. Log into App Store Connect
2. Create both subscription products
3. Use exact Product IDs listed above

### Priority 2: Privacy Policy & Terms Hosting
**MUST BE LIVE** before submission
- Option A: Upload to remembranceapp.com
- Option B: Use GitHub Pages (I can help set up)
- Option C: Update URLs to existing hosted pages

### Priority 3: Build & Upload
**After subscriptions are created:**
1. Clean build folder (⇧⌘K)
2. Set StoreKit Configuration to "None" in scheme (for production)
3. Archive (Product → Archive)
4. Validate & upload

---

## 📞 Need Help With:

**Tell me which of these you need help with:**
1. Creating subscription products in App Store Connect (I can guide you)
2. Hosting privacy policy/terms (I can set up GitHub Pages)
3. Building and archiving for App Store
4. App Store Connect metadata/screenshots
5. Testing with TestFlight

**What should we tackle first?**
