# Remembrance App Style Guide

## 🎨 Color Palette

### Primary Colors

#### Memorial Green (Main Background)
- **RGB**: `(0.2, 0.4, 0.3)`
- **Hex**: `#335A4C`
- **Usage**: Main background color, launch screen, privacy overlay
- **UIColor**: `UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 1.0)`

#### Matte Gold (Accent)
- **RGB**: `(0.7, 0.6, 0.3)`
- **Hex**: `#B39A4C`
- **Usage**: Date boxes, accent elements, borders, highlights
- **Opacity Variants**:
  - Full: Primary accent elements
  - 0.3: Subtle borders and dividers

#### Cream White (Text)
- **RGB**: `(0.98, 0.97, 0.95)`
- **Hex**: `#FAF7F2`
- **Usage**: Primary text on dark backgrounds, date displays
- **Opacity Variants**:
  - Full: Headers and important text
  - 0.8: Secondary text
  - 0.7: Tertiary/subtle text
  - 0.6: Very subtle text

### Secondary Colors

#### Tab Bar Green
- **RGB**: `(0.2, 0.7, 0.4)`
- **Hex**: `#33B366`
- **Usage**: Tab bar accent color in MainTabView

#### Legacy Tab Bar Green
- **RGB**: `(0.2, 0.4, 0.3)`
- **Hex**: `#335A4C`
- **UIColor**: For tab bar background appearance

#### Paper Card Background
- **RGB**: `(0.99, 0.98, 0.96)`
- **Hex**: `#FCF7F5`
- **Usage**: Paper card backgrounds

### Special Purpose Colors

#### Photo Favorite (Heart)
- **Color**: `.red`
- **Usage**: Favorite button when active

#### Pink Accent
- **Color**: `.pink`
- **Usage**: Some UI elements in PaperCardView

#### Secondary Text
- **Color**: `.secondary`
- **Usage**: Subtitle text, less important information

#### White
- **Color**: `.white`
- **Usage**: Text on dark backgrounds, overlays
- **Opacity**: Often used at 0.6-0.8 for subtle effects

## 📐 Typography

### Font Families
- **Primary**: System default (San Francisco on iOS)
- **Serif Option**: "Georgia" (when serif font modifier is applied)

### Font Sizes & Weights
- **Large Title**: `.largeTitle.weight(.light)` - Main headers
- **Title**: `.title` - Section headers
- **Title 2**: `.title2` - Subsection headers
- **Title 3**: `.title3` - Card titles
- **Headline**: `.headline` - Important text
- **Body**: `.body` - Standard content
- **Subheadline**: `.subheadline` - Supporting text
- **Caption**: `.caption` - Small labels
- **Caption 2**: `.caption2` - Very small labels

### Text Styling
- **Italic**: Used for quotes (`.italic()`)
- **Font Weight Options**: `.light`, `.medium`, `.bold`
- **Text Alignment**: `.center` for quotes and centered content
- **Scale Factor Support**: Dynamic text sizing based on user preferences

## 🎯 Layout & Spacing

### Standard Spacing Units
- **Minimal**: 4pt
- **Small**: 8pt
- **Medium**: 12pt
- **Default**: 16pt
- **Large**: 20pt
- **Extra Large**: 24pt
- **Huge**: 30pt

### Common Padding Values
- **Horizontal Padding**: 24pt (standard), 15pt (compact)
- **Vertical Padding**: 16pt (standard), 8pt (compact)
- **Card Padding**: 12pt
- **Button Padding**: Variable based on context

### Layout Positioning
- **Date Box**: 15% from top (additional 15% adjustment applied)
- **Quote Box**: 5% lower than standard for balance
- **Photo Frame**: 90% of screen width, 50% max height

## 🎨 UI Components

### Cards & Containers

#### Date Display Box
```swift
Background: Memorial Green (#335A4C)
Border: Matte Gold (#B39A4C) with opacity 0.3
Corner Radius: 15pt
Padding: 20pt horizontal, 15pt vertical
Shadow: None or very subtle
```

#### Quote Box
```swift
Background: Accent color at 0.1 opacity
Border: Accent color at 0.3 opacity, 1pt width
Corner Radius: 12pt
Padding: 24pt horizontal, 16pt vertical
Shadow: Accent color at 0.1 opacity, radius 4
```

#### Photo Container
```swift
Corner Radius: 12pt
Shadow: Accent color at 0.3 opacity, radius 8
Border: Accent color at 0.2 opacity, 1pt width
Aspect Ratio: Fit within bounds
```

### Buttons

#### Primary Button
```swift
Background: Accent color
Text: White
Corner Radius: 12pt
Padding: Standard system padding
```

#### Icon Buttons
```swift
Size: .title2 for icons
Color: Accent or secondary color
Label: .caption2 below icon
Spacing: 4pt between icon and label
```

#### Tab Bar Items
```swift
Accent Color: #33B366 or #B39A4C
Icon: System SF Symbols
Text: Standard tab labels
```

### Overlays & Modals

#### Full Screen Photo View
```swift
Background: Black
Controls: White text/buttons
Padding: Standard system padding
```

#### Privacy Overlay
```swift
Background: Memorial Green (#335A4C)
Content: White text at various opacities
Animation: Fade in/out
```

## 🎬 Animations

### Standard Animations
- **Spring Animation**: `response: 0.4, dampingFraction: 0.6`
- **Tab Switching**: `.animation(.none)` for instant switching
- **Scale Effects**: 1.1x for active states (like favorite heart)
- **Transitions**: Smooth fade for overlays

### Performance Optimizations
- **GPU Acceleration**: Simplified rendering for gallery
- **Lazy Loading**: 14-day timeline instead of 30
- **Instant Actions**: No animation delays for deletions

## 🎭 Visual Effects

### Shadows
- **Standard**: `radius: 8, opacity: 0.3`
- **Subtle**: `radius: 4, opacity: 0.1`
- **Card Shadow**: Accent color based

### Borders
- **Standard Width**: 1pt
- **Color**: Usually accent color at 0.2-0.3 opacity
- **Style**: Solid stroke with rounded corners

### Gradients
- **Background Options**: Theme-based gradient support
- **Direction**: Top to bottom
- **Colors**: Based on selected theme

## 📱 Responsive Design

### Device Support
- **iOS Minimum**: 16.0
- **Devices**: iPhone and iPad
- **Orientations**: Portrait primary

### Adaptive Layouts
- **Photo Gallery**: 3 columns on standard screens
- **Timeline**: 14-day visible window
- **Text Scaling**: Respects Dynamic Type settings

## 🎯 Design Principles

### Visual Hierarchy
1. **Primary Focus**: Daily photo/memory
2. **Secondary**: Quotes and reflections
3. **Tertiary**: Navigation and controls

### Emotional Design
- **Respectful**: Muted, elegant colors
- **Comforting**: Soft corners, gentle shadows
- **Personal**: Customizable themes and text sizes
- **Memorable**: Gold accents for special elements

### Accessibility
- **High Contrast**: Cream text on dark green
- **Dynamic Type**: Scalable text support
- **Touch Targets**: Minimum 44pt
- **VoiceOver**: Semantic labels for all controls

## 🔧 Implementation Notes

### Color Usage Pattern
```swift
// Primary text on dark background
.foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))

// Accent elements
.foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))

// Background
Color(red: 0.2, green: 0.4, blue: 0.3)
```

### Common Modifiers
```swift
// Standard corner radius
.cornerRadius(12)

// Standard shadow
.shadow(color: accentColor.opacity(0.3), radius: 8)

// Standard padding
.padding(.horizontal, 24)
.padding(.vertical, 16)
```

### Theme Support
The app includes a SettingsViewModel that provides:
- Dynamic color theming
- Font size scaling
- Gradient background options
- Accessibility enhancements

## 📋 Component Library

### Navigation
- Tab bar with 4 main tabs
- Modal sheets for photo import
- Full-screen covers for photo viewing
- Context menus for quick actions

### Controls
- Favorite toggle (heart icon)
- Note editor button
- Full-screen view button
- Photo import button
- Settings gear

### Feedback
- Progress indicators
- Error alerts
- Empty states
- Loading states

## 🎯 Future Considerations

### Potential Enhancements
- Dark mode variant
- Additional theme options
- Custom font support
- More animation options
- Enhanced accessibility features

### Design System Evolution
- Component standardization
- Design token system
- Figma component library
- SwiftUI view library

---

**Last Updated**: January 2025
**Version**: 1.0
**App Version**: Remembrance 1.0