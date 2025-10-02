# App Store Launch - Current Status & Resume Guide

**Last Updated:** October 2, 2025  
**Status:** Ready for build & upload (needs Xcode 16)  
**Target Launch:** Tomorrow

---

## ✅ COMPLETED TASKS

### 1. App Store Connect Setup ✓
- ✅ App created: "Remembrance" 
- ✅ Bundle ID: `stuartgrant.Remembrance`
- ✅ Team ID: `H3NXD6F9S8`

### 2. Subscriptions Created ✓
- ✅ **Monthly:** `com.remembrance.monthly` - $2.99/month - 7 day free trial
- ✅ **Annual:** `com.remembrance.yearly` - $19.99/year - 7 day free trial
- ✅ Both in subscription group: "Premium Access"

### 3. Privacy & Terms Hosted ✓
- ✅ Privacy Policy: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
- ✅ Terms of Service: https://zumu-g.github.io/Remembrance_app/docs/terms.html
- ✅ App code updated with correct URLs
- ✅ GitHub Pages enabled and working

### 4. Code Ready ✓
- ✅ All features complete
- ✅ Settings page with quotes toggle
- ✅ Subscription flow working
- ✅ StoreKit integration ready
- ✅ Git repository up to date
- ✅ Repository public for GitHub Pages

---

## 🔴 PENDING TASKS

### NEXT: Build & Upload (On Home Computer)

**Requirements:**
- ✅ macOS Sonoma (14.0+) or Sequoia
- ✅ Xcode 16 or later
- ✅ iOS 18 SDK (included in Xcode 16)

**Why home computer:** Current Mac has Xcode 15.2 (iOS 17.2 SDK) - App Store requires iOS 18 SDK

---

## 📋 STEP-BY-STEP RESUME GUIDE

### On Your Home Computer:

#### Step 1: Update/Install Xcode 16 (if needed)
1. Open **App Store** on Mac
2. Search for **"Xcode"**
3. Install/Update to **Xcode 16** or later
4. Wait for download (30-60 min)
5. Restart Mac after installation

#### Step 2: Get Latest Code
1. Open Terminal
2. Navigate to project folder, or clone fresh:
   ```bash
   cd ~/Documents
   git clone https://github.com/zumu-g/Remembrance_app.git
   cd Remembrance_app/Remembrance
   ```
3. Or if already cloned:
   ```bash
   cd path/to/Remembrance_app/Remembrance
   git pull origin main
   ```

#### Step 3: Open Project in Xcode 16
1. Double-click `Remembrance.xcodeproj`
2. Opens in Xcode 16
3. If prompted "Update to recommended settings" → Click **"Update"**

#### Step 4: Configure for Production
1. **Edit Scheme** (⌘<):
   - Run → Options → StoreKit Configuration → **"None"**
   - Click "Close"

2. **Select Device Target:**
   - Device dropdown → **"Any iOS Device (arm64)"**

#### Step 5: Build & Archive
1. Clean: **⇧⌘K** (Shift+Cmd+K)
2. Build: **⌘B** (check for errors)
3. Archive: Product → **Archive**
4. Wait for Organizer window

#### Step 6: Upload to App Store Connect
1. Click **"Distribute App"**
2. Choose **"TestFlight & App Store"**
3. Click **"Next"**
4. Choose **"Upload"**
5. Click **"Next"** (keep defaults)
6. Choose **"Automatically manage signing"**
7. Click **"Next"**
8. Review → Click **"Upload"**
9. Wait for upload (2-5 min)
10. Success! → Click **"Done"**

#### Step 7: Verify Upload
1. Go to: https://appstoreconnect.apple.com
2. My Apps → Remembrance
3. TestFlight tab or Build section
4. Build appears in 5-10 minutes (shows "Processing")

#### Step 8: Complete App Store Information
While build is processing:

**Required Fields:**
- [ ] App name: "Remembrance"
- [ ] Subtitle: e.g., "Keep Memories Alive"
- [ ] Description: (detailed description - see template below)
- [ ] Keywords: memorial, remembrance, photos, memories, grief, tribute
- [ ] Screenshots: (all required sizes - iPhone 6.7", 6.5", 5.5")
- [ ] App icon: 1024x1024 (you have this)
- [ ] Privacy Policy URL: https://zumu-g.github.io/Remembrance_app/docs/privacy.html
- [ ] Support URL: (create simple page or use GitHub)
- [ ] Age Rating: 4+ (no mature content)
- [ ] Primary Category: Lifestyle
- [ ] Secondary Category: Health & Fitness (optional)

#### Step 9: Submit for Review
1. Once build shows "Ready to Submit"
2. Click **"Prepare for Submission"**
3. Select your build
4. Fill any remaining fields
5. Click **"Submit for Review"**
6. Set release: **"Manual"** (you control when it goes live)

---

## 📝 APP DESCRIPTION TEMPLATE

**Title:** Remembrance - Keep Memories Alive

**Subtitle:** A beautiful way to honor and remember loved ones

**Description:**
```
Remembrance is a heartfelt memorial app designed to help you keep the memory of your loved ones alive through photos and daily reflections.

KEY FEATURES:
• Display a different cherished photo each day
• 365 inspirational quotes about love, remembrance, and healing
• Beautiful timeline view of all your memories
• Private and secure - all photos stored locally on your device
• Simple, elegant interface focused on what matters

PERFECT FOR:
• Honoring the memory of a loved one who has passed
• Keeping family memories alive
• Daily moments of remembrance and reflection
• Creating a personal digital memorial

SUBSCRIPTION FEATURES:
• 7-day free trial
• Unlimited photo storage
• Full access to all 365 daily quotes
• Complete timeline access
• Monthly ($2.99) or Annual ($19.99 - save 44%) plans

Your photos and memories remain private on your device. We never upload or access your personal content.

Honor their memory. Keep them close. Download Remembrance today.
```

**Keywords:**
```
memorial,remembrance,photos,memories,grief,tribute,loved ones,in memory,bereavement,mourning,healing,memorial photos,family memories,daily remembrance,photo memorial
```

---

## 🔧 TECHNICAL INFO

### Bundle Configuration
- **Bundle ID:** stuartgrant.Remembrance
- **Team ID:** H3NXD6F9S8
- **Version:** 1.0
- **Build:** 1
- **Min iOS:** 16.0
- **Swift Version:** 5

### Subscription Product IDs (Already Created)
- Monthly: `com.remembrance.monthly`
- Annual: `com.remembrance.yearly`

### Important Files
- Privacy Policy: `docs/privacy.html`
- Terms of Service: `docs/terms.html`
- StoreKit Config: `Configuration.storekit` (for testing only)
- Build Guide: `BUILD_AND_SUBMIT_GUIDE.md`

---

## 📞 TROUBLESHOOTING

### If Build Fails:
1. Check Xcode is version 16+: Xcode → About Xcode
2. Check SDK: Should show iOS 18.0 or later
3. Clean build folder: ⇧⌘K
4. Quit and restart Xcode
5. Try archive again

### If Upload Fails:
1. Check internet connection
2. Check Apple Developer account is active
3. Check certificates in Xcode → Preferences → Accounts
4. Try "Download Manual Profiles"
5. Try upload again

### If Screenshots Needed:
1. Run app in Simulator
2. Choose largest iPhone (iPhone 15 Pro Max)
3. Take screenshots of:
   - Today view with photo
   - Timeline view
   - Gallery view
   - Settings page
4. Cmd+S to save screenshots
5. Upload to App Store Connect

---

## ✅ PRE-LAUNCH CHECKLIST

Before submitting for review:

- [ ] Xcode 16 installed on home computer
- [ ] Latest code pulled from GitHub
- [ ] Build successful in Xcode 16
- [ ] Archive created
- [ ] Build uploaded to App Store Connect
- [ ] Build processed (shows "Ready to Submit")
- [ ] All app metadata filled in
- [ ] Screenshots uploaded (all required sizes)
- [ ] Privacy policy URL working
- [ ] Terms of service URL working
- [ ] Age rating selected
- [ ] Category selected
- [ ] Test app one final time
- [ ] Submit for review
- [ ] Set release to "Manual"

---

## 🚀 TIMELINE

**Today (Home Computer):**
- [ ] Update/install Xcode 16 (30-60 min)
- [ ] Build & archive (5 min)
- [ ] Upload to App Store Connect (5 min)
- [ ] Complete metadata (30 min)
- [ ] Submit for review (5 min)

**Tomorrow (If Approved Fast):**
- App Store review (typically 24-48 hours)
- If approved: Release manually when ready

**Normal Timeline:**
- Review: 24-48 hours
- Launch: When approved

---

## 📂 FILES REFERENCE

All documentation in project folder:
- `APP_STORE_LAUNCH_CHECKLIST.md` - Overall checklist
- `BUILD_AND_SUBMIT_GUIDE.md` - Detailed build steps
- `STOREKIT_SETUP.md` - StoreKit configuration guide
- `SUBSCRIPTION_OPTIONS.md` - Subscription setup options
- `CREATE_APP_STORE_CONNECT_APP.md` - App creation guide
- `LAUNCH_STATUS_RESUME.md` - This file (resume guide)

---

## 🎯 QUICK RESUME STEPS

On home computer:
1. ✅ Install Xcode 16
2. ✅ Clone/pull latest code
3. ✅ Open in Xcode 16
4. ✅ Set StoreKit to "None"
5. ✅ Select "Any iOS Device"
6. ✅ Product → Archive
7. ✅ Upload to App Store Connect
8. ✅ Fill in metadata
9. ✅ Submit for review

**You're 90% done! Just need Xcode 16 to finish! 🚀**

---

**Status:** All code complete, subscriptions ready, privacy/terms live.  
**Next:** Build with Xcode 16 on home computer and upload.  
**ETA to submit:** 1-2 hours on home computer.
