# StoreKit Configuration Setup

## Enable StoreKit Testing in Xcode

### Steps:
1. In Xcode, click the **scheme selector** (next to Run/Stop buttons)
   - Shows "Remembrance" with device name

2. Select **"Edit Scheme..."** (or press ⌘<)

3. In left sidebar, select **"Run"**

4. Click **"Options"** tab at the top

5. Find **"StoreKit Configuration"** dropdown

6. Select **"Configuration.storekit"**
   - If not visible: Click "Choose..." and browse to:
     `/Users/stuartgrant_mbp13/Library/Mobile Documents/com~apple~CloudDocs/Remembrance_app/Remembrance/Configuration.storekit`

7. Click **"Close"**

8. **Clean Build Folder:** ⇧⌘K (Shift+Cmd+K)

9. **Build and Run:** ⌘R

### What This Enables:
- ✅ Test subscriptions in Simulator/Device
- ✅ Products load from local Configuration.storekit file
- ✅ No internet required
- ✅ No App Store Connect setup needed
- ✅ 1-week free trial works
- ✅ Test purchases without real money

### Verify It's Working:
Check Xcode console for:
```
🔄 Attempting to load products for IDs: ["com.remembrance.monthly", "com.remembrance.yearly"]
✅ Products loaded: 2 products
  - com.remembrance.monthly: Monthly Subscription - $2.99
  - com.remembrance.yearly: Annual Subscription - $19.99
```

## Alternative: Use App Store Connect (For Production)

If you want real StoreKit (not testing):
1. Create products in App Store Connect
2. Use Product IDs: `com.remembrance.monthly` and `com.remembrance.yearly`
3. Test on real device with TestFlight
4. StoreKit Configuration must be set to "None" in scheme

## Current Status:
- ✅ Configuration.storekit exists with correct products
- ✅ Product IDs match in code
- ❌ StoreKit Configuration not enabled in Xcode scheme (needs fix)
