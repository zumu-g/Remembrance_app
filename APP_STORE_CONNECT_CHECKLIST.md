# App Store Connect Pre-Submit Checklist

## 1. Agreements & Banking
- [ ] Go to: Agreements, Tax, and Banking
- [ ] Verify "Paid Applications" shows as "Active"
- [ ] If not active, Account Holder must sign and accept

## 2. In-App Purchases
- [ ] Navigate to: Your App → In-App Purchases
- [ ] Verify both products show "Ready to Submit":
  - com.remembrance.monthly
  - com.remembrance.yearly
- [ ] If missing info, click each and complete all fields

## 3. App Information Update
- [ ] Go to your app version (1.0)
- [ ] Update Description field with full text including:
  ```
  Terms of Use: https://zumu-g.github.io/Remembrance_app/docs/terms.html
  Privacy Policy: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
  ```
- [ ] Verify these URLs in "App Information" section:
  - Privacy Policy URL: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
  - Support URL: https://zumu-g.github.io/Remembrance_app

## 4. Sandbox Testing
- [ ] Create sandbox tester in Users and Access
- [ ] Sign out of App Store on test device
- [ ] Run app from Xcode
- [ ] Test purchase flow with sandbox account
- [ ] Verify subscription appears correctly

## 5. Build & Submit
- [ ] In Xcode: Increment build number to 2
- [ ] Archive and upload new build
- [ ] Wait 20-30 min for processing
- [ ] Select new build in App Store Connect
- [ ] Add review notes about fixes
- [ ] Submit for review

## Common Issues:
- **"Agreements need attention"**: Account Holder must accept
- **In-App Purchase "Missing Metadata"**: Click product and fill all fields
- **Sandbox purchase fails**: Ensure you're signed out of real App Store account first
- **Build doesn't appear**: Wait up to 30 minutes after upload

## Review Notes Template:
```
Resubmission addressing previous rejection:

1. Fixed In-App Purchase error:
   - Enhanced StoreKit error handling
   - Added comprehensive logging for sandbox environment
   - Improved transaction verification

2. Added Terms of Use:
   - Added Terms of Use link in app description
   - Links already present in subscription view

Note: Account Holder has accepted Paid Apps Agreement.
All subscription information properly displayed in-app.
```