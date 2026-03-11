# Create App in App Store Connect

## Prerequisites Needed:

Before creating the app, you need:
1. ✅ Apple Developer Account (enrolled - $99/year)
2. ✅ Bundle Identifier registered
3. ✅ App name available

## Step-by-Step Instructions:

### Step 1: Verify Your Apple Developer Account
1. Go to: https://developer.apple.com/account
2. Sign in
3. Verify you see "Account" and "Certificates, Identifiers & Profiles"
4. Check enrollment status is "Active"

### Step 2: Register Bundle Identifier (If Not Done)
1. In developer.apple.com/account
2. Click **"Certificates, Identifiers & Profiles"**
3. Click **"Identifiers"** in left sidebar
4. Click **"+"** button (top right)
5. Select **"App IDs"** → Continue
6. Select **"App"** → Continue
7. Fill in:
   - **Description:** Remembrance
   - **Bundle ID:** `stuartgrant.Remembrance` (must match Xcode)
   - **Capabilities:** Enable "In-App Purchase"
8. Click **"Continue"** → **"Register"**

### Step 3: Create App in App Store Connect
1. Go to: https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Click **"+"** button (top left)
4. Select **"New App"**

### Step 4: Fill in New App Form
- **Platforms:** iOS
- **Name:** Remembrance
- **Primary Language:** English (U.S.)
- **Bundle ID:** Select `stuartgrant.Remembrance` from dropdown
  - ⚠️ If not in dropdown, complete Step 2 first
- **SKU:** remembrance-app-2025 (or any unique identifier)
- **User Access:** Full Access

### Step 5: Click "Create"

Your app is now created! You can now:
- Add subscriptions
- Upload builds
- Configure metadata

---

## If Bundle ID is Missing from Dropdown:

### Check in Xcode:
1. Open project in Xcode
2. Select project in navigator (top item)
3. Select "Remembrance" target
4. Go to "Signing & Capabilities" tab
5. Check "Bundle Identifier" value

**Current Bundle ID should be:** `stuartgrant.Remembrance`

### If Different:
Either:
- A) Update Xcode to match App Store Connect
- B) Register the Bundle ID shown in Xcode

---

## Common Issues:

### "App name already taken"
- Try: "Remembrance - Memorial Photos"
- Or: "Remembrance App"
- Or: Add subtitle later in metadata

### "Bundle ID already registered to another account"
- Must use a unique Bundle ID
- Change in Xcode to: `stuartgrant.RemembranceApp` or similar
- Re-register in developer portal

### "Developer account not enrolled"
- Must have active $99/year Apple Developer Program membership
- Enroll at: https://developer.apple.com/programs/enroll/

---

## Quick Verification Checklist:

- [ ] Apple Developer account is active ($99/year paid)
- [ ] Bundle ID registered: stuartgrant.Remembrance
- [ ] Bundle ID has "In-App Purchase" capability enabled
- [ ] App created in App Store Connect
- [ ] App name "Remembrance" available (or alternative chosen)

**Current Status:** Creating app in App Store Connect
**Next Step:** Add subscriptions to the newly created app
