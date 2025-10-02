# Build & Submit to App Store - Step by Step

## Before You Start:
✅ Subscriptions created in App Store Connect
✅ Privacy & Terms live on GitHub Pages
✅ Code is up to date

---

## STEP 1: Prepare Xcode (5 minutes)

### A. Disable StoreKit Configuration (IMPORTANT!)
1. In Xcode, click the **scheme dropdown** (next to Run/Stop buttons)
2. Click **"Edit Scheme..."** (or press ⌘<)
3. Select **"Run"** in left sidebar
4. Click **"Options"** tab
5. Find **"StoreKit Configuration"**
6. Set to **"None"** (NOT Configuration.storekit)
7. Click **"Close"**

**Why:** Production builds must use real App Store products, not test config.

### B. Select Device Target
1. Click **device dropdown** (next to scheme)
2. Select **"Any iOS Device (arm64)"**

**Why:** Can't archive for simulator, must be real device target.

---

## STEP 2: Build & Archive (5 minutes)

### A. Clean Build
1. Press **⇧⌘K** (Shift + Cmd + K)
2. Or: Menu → Product → Clean Build Folder

### B. Test Build First
1. Press **⌘B** (Cmd + B) to build
2. Wait for build to complete
3. Check for any errors in the console
4. If errors appear, STOP and tell me

### C. Create Archive
1. Menu → Product → **Archive**
2. Wait 1-2 minutes for archive to complete
3. Organizer window opens automatically

---

## STEP 3: Upload to App Store Connect (10 minutes)

### In Organizer Window:

1. **Click "Distribute App"** button (blue, on right)

2. **Select destination:**
   - Choose: **"App Store Connect"** ✓
   - Click **"Next"**

3. **Select method:**
   - Choose: **"Upload"** ✓
   - Click **"Next"**

4. **App Store Connect distribution:**
   - Keep all defaults checked
   - Click **"Next"**

5. **Re-sign options:**
   - Choose: **"Automatically manage signing"** ✓
   - Click **"Next"**

6. **Review archive:**
   - Check app name, version, bundle ID
   - Click **"Upload"**

7. **Wait for upload:**
   - Progress bar appears
   - Takes 2-5 minutes
   - Don't close Xcode during upload

8. **Success!**
   - You'll see "Upload Successful" message
   - Click **"Done"**

---

## STEP 4: Verify Upload (2 minutes)

1. Go to App Store Connect: https://appstoreconnect.apple.com
2. Click **"My Apps"** → **"Remembrance"**
3. Look for **"TestFlight"** tab or **Build** section
4. Your build should appear in 5-10 minutes (processing)
5. Status will show "Processing" then "Ready to Submit"

---

## STEP 5: Complete App Information (15 minutes)

While build is processing, fill in App Store Connect:

### Required Fields:
- [ ] App name: "Remembrance"
- [ ] Subtitle (optional but recommended)
- [ ] Description (detailed, 4000 char max)
- [ ] Keywords (100 char max)
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] Screenshots (required - all sizes)
- [ ] App icon 1024x1024 (required)
- [ ] Privacy Policy URL: (already set)
- [ ] Age Rating: Select appropriate rating
- [ ] Category: Primary (Lifestyle or Health & Fitness)

---

## Common Issues & Solutions:

### "No accounts with App Store Connect access"
- Go to Xcode → Preferences → Accounts
- Make sure your Apple ID is added
- Click "Download Manual Profiles"

### "Signing requires a development team"
- Select your project in navigator
- Go to Signing & Capabilities
- Team: Select your developer account

### "Archive not showing in Organizer"
- Window → Organizer → Archives tab
- Should be there

### "Upload failed - Invalid Swift Support"
- Normal for first upload
- Xcode includes Swift frameworks automatically
- Re-try upload

---

## After Upload Success:

✅ Build uploaded to App Store Connect
✅ Wait 5-10 minutes for processing
✅ Fill in app metadata while waiting
✅ Add screenshots
✅ Submit for review

---

## Need Help?
If you get stuck at any step, tell me:
1. Which step you're on
2. What error/message you see
3. Screenshot if helpful

**Start with STEP 1A now!**
