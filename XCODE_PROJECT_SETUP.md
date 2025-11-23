# Xcode Project Setup - Adding New Files

## New Files to Add to Xcode Project

The following new Swift files have been created and need to be added to your Xcode project:

### 1. Subscription & Payments
- `StoreKitManager.swift` - Handles all subscription logic and trial management
- `PaywallView.swift` - Beautiful paywall screen for when trial expires
- `Configuration.storekit` - StoreKit configuration for testing subscriptions

### 2. Onboarding
- `OnboardingView.swift` - Complete onboarding flow for new users

## How to Add Files to Xcode Project

### Step 1: Open Xcode Project
1. Open `Remembrance.xcodeproj` in Xcode
2. In the left sidebar, right-click on the "Remembrance" folder

### Step 2: Add Swift Files
1. Select "Add Files to 'Remembrance'..."
2. Navigate to the Remembrance folder
3. Select these files:
   - `StoreKitManager.swift`
   - `PaywallView.swift`
   - `OnboardingView.swift`
4. Make sure these options are checked:
   - ✅ Copy items if needed (unchecked if files are already in project folder)
   - ✅ Create groups
   - ✅ Add to target: Remembrance
5. Click "Add"

### Step 3: Add StoreKit Configuration
1. Right-click on the "Remembrance" folder again
2. Select "Add Files to 'Remembrance'..."
3. Select `Configuration.storekit`
4. Click "Add"

### Step 4: Configure StoreKit for Testing
1. Select your scheme (Remembrance) in Xcode
2. Click "Edit Scheme..."
3. Select "Run" on the left
4. Go to the "Options" tab
5. Under "StoreKit Configuration", select "Configuration.storekit"
6. Click "Close"

### Step 5: Add StoreKit Capability
1. Select the Remembrance project in the navigator
2. Select the Remembrance target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "In-App Purchase" capability

### Step 6: Verify Build Settings
Ensure these settings are correct:
- iOS Deployment Target: 16.0 or later
- Swift Language Version: 5.0 or later

## Testing the Integration

### 1. Build and Run
- Press Cmd+B to build the project
- Fix any build errors (usually missing imports or references)

### 2. Test Onboarding Flow
For new users (or reset the app):
```swift
// To reset onboarding for testing, add this temporarily:
UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
UserDefaults.standard.removeObject(forKey: "trialStartDate")
```

### 3. Test Subscription Flow
The StoreKit Configuration file includes:
- Monthly subscription: $2.99/month with 7-day trial
- Annual subscription: $19.99/year with 7-day trial

In the simulator:
1. The trial will start automatically
2. You can test purchases (they're free in sandbox)
3. Subscriptions renew quickly in sandbox (minutes instead of months)

## Important Files Modified

These existing files were updated to integrate the new features:

### `RemembranceApp.swift`
- Added onboarding presentation logic
- Added `setMainPhoto()` method to PhotoStore
- Integrated onboarding state management

### `SettingsTabView.swift`
- Added subscription status display
- Integrated StoreKitManager
- Added restore purchases functionality

### `ContentView.swift`
- Added paywall presentation for expired trials
- Integrated subscription status checking

## Troubleshooting

### If OnboardingView causes build errors:
The onboarding is already set up in the code but commented out. To enable:
1. Make sure `OnboardingView.swift` is added to the project
2. Uncomment the onboarding-related code in `RemembranceApp.swift`

### If StoreKit doesn't work:
1. Make sure you're signed in with a sandbox account
2. Settings → App Store → Sandbox Account
3. Use a test email that's not your real Apple ID

### If subscriptions don't appear:
1. Make sure the StoreKit Configuration is selected in the scheme
2. Check that product IDs match exactly:
   - `com.remembrance.monthly`
   - `com.remembrance.yearly`

## Next Steps

After adding these files to Xcode:

1. **Test locally** with the StoreKit Configuration
2. **Configure App Store Connect** (see APP_STORE_CONNECT_SETUP.md)
3. **Upload to TestFlight** for beta testing
4. **Submit for App Review** once testing is complete

## Files Location Summary

```
Remembrance_app/
├── Remembrance/
│   ├── StoreKitManager.swift (NEW - Add to Xcode)
│   ├── PaywallView.swift (NEW - Add to Xcode)
│   ├── OnboardingView.swift (NEW - Add to Xcode)
│   ├── Configuration.storekit (NEW - Add to Xcode)
│   ├── RemembranceApp.swift (MODIFIED)
│   ├── ContentView.swift (MODIFIED)
│   └── SettingsTabView.swift (MODIFIED)
├── privacy-policy.html (Host on website)
├── terms-of-service.html (Host on website)
├── APP_STORE_METADATA.md (Reference document)
├── APP_STORE_CONNECT_SETUP.md (Setup guide)
└── XCODE_PROJECT_SETUP.md (This file)
```

## Important Notes

- The 7-day trial starts automatically on first launch
- Trial status is stored in UserDefaults
- Subscriptions are handled entirely by StoreKit 2
- All photos remain local on device (privacy-first approach)
- The onboarding helps users understand the app and add initial photos

Once these files are added to Xcode and the project builds successfully, your app will have a complete subscription model with onboarding ready for the App Store!