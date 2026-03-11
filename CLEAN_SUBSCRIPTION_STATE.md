# Cleaning Subscription State for Testing

## If Running from Xcode:

### 1. Reset StoreKit Testing
- In Xcode, go to Product → Scheme → Edit Scheme
- Select "Run" on the left
- Go to "Options" tab
- Under StoreKit Configuration, select "None" (instead of Configuration.storekit)
- This ensures you're testing against the real sandbox, not local config

### 2. Clear App Data
- Delete the app from your device/simulator
- In Xcode: Product → Clean Build Folder (⇧⌘K)
- Reinstall fresh

### 3. Sign Out of Sandbox Account
- On device: Settings → App Store → Sandbox Account → Sign Out
- This clears any sandbox purchases

## Check in SettingsTabView

The subscription status is shown based on this logic in SettingsTabView:
- If `storeManager.hasActiveSubscription()` returns true, it shows subscription details
- This checks if `purchasedProductIDs` is not empty

## To Debug:
Add this temporary code to see what's happening:

```swift
.onAppear {
    print("DEBUG: Has active subscription: \(storeManager.hasActiveSubscription())")
    print("DEBUG: Purchased IDs: \(storeManager.purchasedProductIDs)")
    print("DEBUG: Subscription type: \(storeManager.currentSubscriptionType ?? "none")")
}
```

## For App Store Submission:
- The sandbox/test purchases won't affect real users
- Apple reviewers test in sandbox environment
- Real users start with no subscriptions