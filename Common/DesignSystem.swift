import SwiftUI

struct DesignSystem {
    // Colors
    static let primaryBlue = Color(hex: "#3B6BA5")
    static let teal = Color(hex: "#3AA79D")
    static let background = Color(hex: "#1E1E1E")
    static let success = Color.success
    static let warning = Color.warning
    static let error = Color.error
    static let info = Color.info

    // Domain Colors
    static let healthColor = Color(hex: "#FF6B6B")
    static let financeColor = Color(hex: "#4ECDC4")
    static let productivityColor = Color(hex: "#45B7D1")
    static let mindfulnessColor = Color(hex: "#96CEB4")

    // Typography
    static let fontFamily = "SF Pro"
    static let h1 = Font.system(size: 32, weight: .bold)
    static let h2 = Font.system(size: 24, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)

    // Spacing
    static let spacing: CGFloat = 8
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32

    // Shadows
    static let shadowSmall = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let shadowMedium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let shadowLarge = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)

    // Border Radius
    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 20
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Shadow {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}