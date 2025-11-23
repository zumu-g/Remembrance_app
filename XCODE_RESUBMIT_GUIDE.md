# Xcode Update and App Store Resubmission Guide

## Step 1: Open Project in Xcode
1. Open Xcode
2. File → Open → Navigate to: `/Users/stu_imac/Library/Mobile Documents/com~apple~CloudDocs/Remembrance_app/Remembrance/Remembrance.xcodeproj`

## Step 2: Update Version/Build Number
1. Select the project in navigator (blue icon at top)
2. Select "Remembrance" target
3. Under "General" tab:
   - Keep Version: `1.0`
   - Increment Build: Change from `1` to `2` (or whatever the next number is)

## Step 3: Clean and Build
1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)
3. Ensure no errors appear

## Step 4: Archive the App
1. Select target device: "Any iOS Device (arm64)"
2. Product → Archive (this takes a few minutes)
3. Organizer window will open automatically when done

## Step 5: Upload to App Store Connect
In the Organizer window:
1. Select your new archive (should be at the top)
2. Click "Distribute App"
3. Choose "App Store Connect" → Next
4. Choose "Upload" → Next
5. Accept defaults for:
   - App Store Connect distribution options
   - Re-sign options
6. Review and click "Upload"

## Step 6: Update App Store Connect
After upload completes (5-10 minutes):

1. Go to https://appstoreconnect.apple.com
2. Select your app "Remembrance"
3. Click on the version being reviewed

### Update App Information:
1. **App Description**: Copy the updated description from APP_STORE_METADATA.md (includes Terms of Use link)
2. **What's New**: Keep as "Initial release"
3. **Support URL**: `https://zumu-g.github.io/Remembrance_app`
4. **Marketing URL**: `https://zumu-g.github.io/Remembrance_app`

### Update Build:
1. Scroll to "Build" section
2. Click the "+" or "Add Build"
3. Select your new build (version 1.0, build 2)
4. It may take 20-30 minutes to appear after upload

### Add Review Notes:
In "App Review Information" section, add:
```
This resubmission addresses the following issues:
1. Enhanced StoreKit error handling for sandbox environment
2. Added Terms of Use link to app description

Note: The Account Holder must accept the Paid Apps Agreement for in-app purchases to function properly.

All subscription information is properly displayed in-app:
- Subscription title and duration
- Pricing information
- Terms of Use and Privacy Policy links
```

## Step 7: Submit for Review
1. Click "Save" at the top
2. Click "Add for Review"
3. Answer export compliance questions (usually "No")
4. Submit to App Review

## Important Reminders:
- ✅ Ensure Paid Apps Agreement is accepted in App Store Connect
- ✅ Verify in-app purchases show "Ready to Submit" status
- ✅ Test purchases work in sandbox before submitting
- ✅ All metadata URLs are working (Terms, Privacy, etc.)

## Troubleshooting:
- If archive doesn't appear: Check build settings match (iOS Deployment Target, etc.)
- If upload fails: Check your certificates and provisioning profiles
- If build doesn't appear in App Store Connect: Wait 30 minutes and refresh

## Build Settings to Verify:
- iOS Deployment Target: 16.0
- Bundle Identifier: `com.remembrance.app` (or your actual identifier)
- Version: 1.0
- Build: 2 (incremented from previous submission)