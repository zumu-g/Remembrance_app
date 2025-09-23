import SwiftUI

extension Font {
    // Using Baskerville for a more formal, classic look
    static let serifTitle = Font.custom("Baskerville", size: 28).weight(.medium)
    static let serifTitle2 = Font.custom("Baskerville", size: 22).weight(.medium)
    static let serifTitle3 = Font.custom("Baskerville", size: 18).weight(.medium)
    static let serifHeadline = Font.custom("Baskerville", size: 17).weight(.medium)
    static let serifSubheadline = Font.custom("Baskerville", size: 15).weight(.regular)
    static let serifBody = Font.custom("Baskerville", size: 16).weight(.regular)
    static let serifCallout = Font.custom("Baskerville", size: 15).weight(.regular)
    static let serifCaption = Font.custom("Baskerville", size: 12).weight(.regular)
    static let serifCaption2 = Font.custom("Baskerville", size: 11).weight(.regular)
    static let serifFootnote = Font.custom("Baskerville", size: 13).weight(.regular)
    
    // Large title for special occasions - using a more elegant weight
    static let serifLargeTitle = Font.custom("Baskerville", size: 32).weight(.regular)
}

struct SerifTextStyle: ViewModifier {
    let style: Font
    
    func body(content: Content) -> some View {
        content
            .font(style)
    }
}

extension View {
    func serifFont(_ style: Font) -> some View {
        self.modifier(SerifTextStyle(style: style))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Remembrance")
            .serifFont(.serifLargeTitle)
            .foregroundColor(.primary)
        
        Text("A gentle way to honor and remember your mother through daily photos and memories.")
            .serifFont(.serifBody)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        Text("Daily Reminders")
            .serifFont(.serifHeadline)
        
        Text("Today's Memory")
            .serifFont(.serifTitle2)
        
        Text("Version 1.0")
            .serifFont(.serifCaption)
            .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}