# App Store Connect Setup Guide

## Step 1: Create App in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - App Name: Remembrance
   - Primary Language: English (U.S.)
   - Bundle ID: stuartgrant.Remembrance
   - SKU: REMEMBRANCE2025
   - User Access: Full Access

## Step 2: Configure In-App Purchases

### Create Subscription Group
1. Go to "In-App Purchases" → "Manage"
2. Create Auto-Renewable Subscription Group:
   - Reference Name: Premium Access
   - Subscription Group Display Name: Premium Access

### Add Monthly Subscription
1. Click "+" in the subscription group
2. Configure:
   - Reference Name: Monthly Subscription
   - Product ID: com.remembrance.monthly
   - Subscription Duration: 1 Month
   - Subscription Price: $2.99
   - Introductory Offer: 7 days free trial (Pay As You Go)
   - Promotional Offer: None initially

### Add Annual Subscription
1. Click "+" in the subscription group
2. Configure:
   - Reference Name: Annual Subscription
   - Product ID: com.remembrance.yearly
   - Subscription Duration: 1 Year
   - Subscription Price: $19.99
   - Introductory Offer: 7 days free trial (Pay As You Go)
   - Promotional Offer: None initially

### Subscription Group Localization
Add description for the subscription group:
"Get unlimited access to all Remembrance features including unlimited photo storage, 365 daily quotes, and memorial timeline."

## Step 3: App Information

### General Information
- Category: Lifestyle
- Content Rights: Yes, I own the rights
- Age Rating: 4+
- Made for Kids: No

### Pricing and Availability
- Price: Free (with In-App Purchases)
- Available in: All territories

### Privacy Policy
- Privacy Policy URL: https://remembranceapp.com/privacy
- Terms of Service URL: https://remembranceapp.com/terms

## Step 4: App Store Listing

### App Store Information
- Name: Remembrance - Memorial Photos
- Subtitle: Daily memories of loved ones
- Description: [Use from APP_STORE_METADATA.md]
- Keywords: memorial, remembrance, photos, memories, loved ones
- Support URL: https://remembranceapp.com/support
- Marketing URL: https://remembranceapp.com

### Screenshots
Upload for each device size:
- 6.7" (iPhone 15 Pro Max): 1290 x 2796
- 6.5" (iPhone 14 Plus): 1284 x 2778
- 5.5" (iPhone 8 Plus): 1242 x 2208

## Step 5: TestFlight Setup

1. Go to TestFlight tab
2. Add Internal Testing Group:
   - Name: Development Team
   - Add your Apple ID as tester

3. Build submission:
   - Upload build via Xcode
   - Add build to internal testing group
   - Test subscription flow thoroughly

## Step 6: Subscription Testing

### Test Scenarios
1. **New User Flow:**
   - Install fresh app
   - Verify 7-day trial starts
   - Check trial day counter

2. **Purchase Flow:**
   - Try monthly subscription
   - Try annual subscription
   - Verify unlocked features

3. **Restore Flow:**
   - Delete and reinstall app
   - Test "Restore Purchases"
   - Verify subscription restored

4. **Expiration Flow:**
   - Let trial expire (sandbox accelerated)
   - Verify paywall appears
   - Test resubscription

## Step 7: App Review Submission

### Review Information
- Demo account: Not required
- Notes: "This is a memorial photo app that helps users remember loved ones. Users add their own photos. The app includes a 7-day free trial."

### App Review Checklist
- [ ] All screenshots uploaded
- [ ] App description complete
- [ ] In-app purchases configured
- [ ] Privacy policy live at URL
- [ ] Terms of service live at URL
- [ ] TestFlight testing complete
- [ ] Subscription descriptions clear
- [ ] Contact information accurate

## Step 8: Post-Launch

### Monitor
- Review subscription analytics
- Check for user reviews
- Monitor crash reports
- Track conversion rates

### Marketing
- Prepare press release
- Create social media accounts
- Reach out to grief support communities
- Consider App Store Search Ads

## Important URLs

- App Store Connect: https://appstoreconnect.apple.com
- Apple Developer: https://developer.apple.com
- Subscription Guidelines: https://developer.apple.com/app-store/subscriptions/

## Sandbox Testing Timing

In sandbox environment:
- 1 week = 3 minutes
- 1 month = 5 minutes
- 1 year = 1 hour

This accelerated timing helps test subscription flows quickly.

## Revenue Share

Apple's commission:
- Year 1: 30% (you keep 70%)
- Year 2+: 15% (you keep 85%) for subscribers who maintain subscription

## Support Response Template

For subscription issues:
```
Thank you for contacting Remembrance support.

To manage your subscription:
1. Open Settings on your iPhone
2. Tap your name at the top
3. Tap Subscriptions
4. Find Remembrance and tap it
5. Here you can change or cancel your subscription

If you're having trouble, you can also visit:
https://apps.apple.com/account/subscriptions

For refund requests, please contact Apple Support directly as they handle all payment processing.

Best regards,
Remembrance Support
```