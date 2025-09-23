# App Icon Conversion Guide

## Your Beautiful Icon Design
✅ SVG saved as `icon.svg` in the project
- Dark green gradient background (memorial/nature theme)
- Red heart symbol in center
- "365 DAYS" text
- Circular progress indicator
- Decorative elements

## Quick Conversion Options

### Option 1: Online Converter (Recommended - Easiest)
1. Go to **https://appicon.co** or **https://makeappicon.com**
2. Upload your `icon.svg` file
3. Download the generated zip file
4. Extract and copy all PNG files to: `365daysofMum/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Using macOS Terminal (If you have rsvg-convert)
```bash
# Install rsvg-convert if not available
brew install librsvg

# Navigate to your project directory
cd "/Users/stuartgrant_mbp13/Library/Mobile Documents/com~apple~CloudDocs/365 Days of Mum app/365daysofMum"

# Convert to all required sizes
rsvg-convert -w 40 -h 40 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-20x20@2x.png"
rsvg-convert -w 60 -h 60 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-20x20@3x.png"
rsvg-convert -w 58 -h 58 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-29x29@2x.png"
rsvg-convert -w 87 -h 87 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-29x29@3x.png"
rsvg-convert -w 80 -h 80 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-40x40@2x.png"
rsvg-convert -w 120 -h 120 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-40x40@3x.png"
rsvg-convert -w 120 -h 120 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-60x60@2x.png"
rsvg-convert -w 180 -h 180 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-60x60@3x.png"
rsvg-convert -w 20 -h 20 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-20x20.png"
rsvg-convert -w 29 -h 29 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-29x29.png"
rsvg-convert -w 40 -h 40 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-40x40.png"
rsvg-convert -w 76 -h 76 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-76x76.png"
rsvg-convert -w 152 -h 152 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-76x76@2x.png"
rsvg-convert -w 167 -h 167 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-83.5x83.5@2x.png"
rsvg-convert -w 1024 -h 1024 icon.svg -o "365daysofMum/Assets.xcassets/AppIcon.appiconset/AppIcon-1024x1024.png"
```

### Option 3: Using Figma/Sketch/Adobe Illustrator
1. Import `icon.svg` into your design tool
2. Export at the following sizes:
   - 20×20, 40×40, 58×58, 60×60, 76×76, 80×80, 87×87, 120×120, 152×152, 167×167, 180×180, 1024×1024
3. Save with exact filenames as listed in Contents.json

## Required Files Checklist
- [ ] `AppIcon-20x20.png` (20×20)
- [ ] `AppIcon-20x20@2x.png` (40×40)
- [ ] `AppIcon-20x20@3x.png` (60×60)
- [ ] `AppIcon-29x29.png` (29×29)
- [ ] `AppIcon-29x29@2x.png` (58×58)
- [ ] `AppIcon-29x29@3x.png` (87×87)
- [ ] `AppIcon-40x40.png` (40×40)
- [ ] `AppIcon-40x40@2x.png` (80×80)
- [ ] `AppIcon-40x40@3x.png` (120×120)
- [ ] `AppIcon-60x60@2x.png` (120×120)
- [ ] `AppIcon-60x60@3x.png` (180×180)
- [ ] `AppIcon-76x76.png` (76×76)
- [ ] `AppIcon-76x76@2x.png` (152×152)
- [ ] `AppIcon-83.5x83.5@2x.png` (167×167)
- [ ] `AppIcon-1024x1024.png` (1024×1024)

## Verification
After adding the PNG files:
1. Build the project in Xcode
2. Check for any warnings in the AppIcon.appiconset
3. Test on device/simulator to see the icon on home screen
4. Verify the icon looks crisp at all sizes

## Design Notes
Your icon design is perfect for a memorial app:
- **Dark green**: Represents growth, life, and nature
- **Red heart**: Universal symbol of love and remembrance
- **365 DAYS**: Clear app purpose
- **Progress circle**: Journey through grief
- **Professional appearance**: Suitable for App Store

The design will scale beautifully from the smallest (20pt) to largest (1024pt) sizes.