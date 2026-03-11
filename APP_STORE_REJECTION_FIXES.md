# App Store Rejection Fixes - November 2025

## Issues Fixed

### 1. StoreKit Receipt Validation (Guideline 2.1)
**Problem**: In-app purchase error when attempting to make a purchase in the review environment.

**Solution Implemented**:
- Enhanced error handling in StoreKitManager.swift
- Added detailed logging for debugging
- Improved transaction verification with better error messages
- Added specific error handling for different StoreKit error types

**Additional Steps Required**:
1. Ensure the Account Holder has accepted the **Paid Apps Agreement** in App Store Connect
2. Verify the in-app purchases are set to "Ready to Submit" status in App Store Connect
3. Test purchases in sandbox environment before resubmitting

### 2. Terms of Use Link (Guideline 3.1.2)
**Problem**: Missing Terms of Use (EULA) link in App Store metadata.

**Solution Implemented**:
- Updated APP_STORE_METADATA.md with correct URLs:
  - Terms of Use: https://zumu-g.github.io/Remembrance_app/docs/terms.html
  - Privacy Policy: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
- Added Terms of Use and Privacy Policy links directly in the App Description
- Verified links are working and accessible

**In-App Implementation** (Already Present):
- SubscriptionView displays all required information:
  - Title of subscription ✓
  - Length of subscription ✓
  - Price of subscription ✓
  - Price per unit (for yearly) ✓
  - Links to Privacy Policy and Terms of Use ✓

## Pre-Submission Checklist

### App Store Connect Actions:
- [ ] Accept Paid Apps Agreement (Account Holder must do this)
- [ ] Verify in-app purchases status is "Ready to Submit"
- [ ] Update App Description with the Terms of Use link
- [ ] Update Privacy Policy URL field
- [ ] Update Terms of Service URL field

### Testing:
- [ ] Test purchases in sandbox environment
- [ ] Verify all subscription information displays correctly
- [ ] Confirm Terms of Use and Privacy Policy links work

### Code Changes Made:
- [x] Enhanced StoreKit error handling
- [x] Added comprehensive logging
- [x] Improved transaction verification
- [x] Updated metadata with correct URLs

## Key URLs for App Store Connect:
- Support URL: https://zumu-g.github.io/Remembrance_app
- Privacy Policy: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
- Terms of Service: https://zumu-g.github.io/Remembrance_app/docs/terms.html
- Marketing URL: https://zumu-g.github.io/Remembrance_app

## Notes:
- The app uses StoreKit 2, which handles receipt validation automatically
- No server-side receipt validation is needed
- All subscription data is handled locally on device