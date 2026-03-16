# App Store Rejection Fixes

## December 2025 Rejection - FIXES APPLIED

**Rejection Date**: December 2, 2025
**Fixes Applied**: December 3, 2025
**Status**: Ready for resubmission

### Issues and Fixes:

#### 1. Guideline 1.5 - Support URL Required Login
**Problem**: Support URL pointed to GitHub repo which requires login to communicate.

**Solution**:
- Created standalone support page: `docs/support.html`
- Page includes:
  - Direct email contact (no login required)
  - FAQ section
  - Links to Privacy Policy and Terms of Use
  - App information

**New Support URL**: `https://zumu-g.github.io/Remembrance_app/docs/support.html`

#### 2. Guideline 3.1.2 - Missing Legal Links in Binary
**Problem**: App binary missing functional links to Terms of Use and Privacy Policy.

**Solution**:
- Added legal links to `SettingsTabView.swift` in About section:
  - Privacy Policy
  - Terms of Use
  - Support
- Added legal links directly above purchase buttons in `PaywallView.swift`
- Links are now visible in pre-purchase workflow as required

#### 3. Guideline 3.1.2 - Unclear Subscription Features
**Problem**: App did not clearly describe what user receives with subscription.

**Solution**:
- Added "With Premium you get:" section in `PaywallView.swift` with clear bullet points:
  - Unlimited photo storage for all your memories
  - 365 unique inspirational daily quotes
  - Full timeline access to view past memories
  - Daily reminder notifications

### Files Modified:
```
PaywallView.swift      - Legal links + feature descriptions
SettingsTabView.swift  - Legal links in About section
docs/support.html      - NEW: Standalone support page
```

### Resubmission Checklist:
- [x] Code changes committed to git
- [x] Changes pushed to GitHub
- [ ] Build new archive in Xcode (Product > Archive)
- [ ] Upload to App Store Connect
- [ ] Update Support URL in App Store Connect to: `https://zumu-g.github.io/Remembrance_app/docs/support.html`
- [ ] Resubmit In-App Purchase products with new binary

---

## November 2025 Rejection - RESOLVED

### 1. StoreKit Receipt Validation (Guideline 2.1)
**Problem**: In-app purchase error when attempting to make a purchase in the review environment.

**Solution Implemented**:
- Enhanced error handling in StoreKitManager.swift
- Added sandbox receipt detection for App Store review
- Improved transaction verification with better error messages

### 2. Terms of Use Link (Guideline 3.1.2)
**Problem**: Missing Terms of Use (EULA) link in App Store metadata.

**Solution Implemented**:
- Created GitHub Pages with Terms and Privacy Policy
- Added links in PaywallView termsSection

---

## Key URLs for App Store Connect:

| Field | URL |
|-------|-----|
| **Support URL** | `https://zumu-g.github.io/Remembrance_app/docs/support.html` |
| **Privacy Policy** | `https://zumu-g.github.io/Remembrance_app/docs/privacy.html` |
| **Terms of Service** | `https://zumu-g.github.io/Remembrance_app/docs/terms.html` |

## Notes:
- The app uses StoreKit 2 with automatic receipt validation
- All subscription data is handled locally on device
- GitHub Pages hosts all legal/support documentation (no login required)
