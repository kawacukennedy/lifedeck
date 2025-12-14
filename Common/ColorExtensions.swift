import SwiftUI

extension Color {
    static let primary = DesignSystem.primaryBlue
    static let secondary = DesignSystem.teal
    static let background = DesignSystem.background
    static let success = DesignSystem.success
    static let warning = DesignSystem.warning
    static let error = DesignSystem.error

    static let health = DesignSystem.healthColor
    static let finance = DesignSystem.financeColor
    static let productivity = DesignSystem.productivityColor
    static let mindfulness = DesignSystem.mindfulnessColor

    // Additional colors for themes
    static let midnightBlue = Color(hex: "#1F2A37")
    static let steelBlue = Color(hex: "#3B6BA5")
    static let premiumGold = Color(hex: "#FFD700")

    // Additional semantic colors
    static let info = Color(hex: "#64B5F6")
    static let warning = Color(hex: "#FFB300")
    static let error = Color(hex: "#E57373")
    static let success = Color(hex: "#4CAF50")
}