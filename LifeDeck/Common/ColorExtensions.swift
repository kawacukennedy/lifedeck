import SwiftUI
import UIKit

// MARK: - Life Domain Enum
enum LifeDomain: String, CaseIterable, Identifiable {
    case health = "health"
    case finance = "finance" 
    case productivity = "productivity"
    case mindfulness = "mindfulness"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .health: return "Health"
        case .finance: return "Finance"
        case .productivity: return "Productivity"
        case .mindfulness: return "Mindfulness"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "figure.run" // 🏃
        case .finance: return "dollarsign.circle" // 💰
        case .productivity: return "timer" // ⏳
        case .mindfulness: return "leaf" // 🧘
        }
    }
    
    var emoji: String {
        switch self {
        case .health: return "🏃"
        case .finance: return "💰"
        case .productivity: return "⏳"
        case .mindfulness: return "🧘"
        }
    }
}

// MARK: - LifeDeck Color Palette
extension Color {
    
    // MARK: - Primary Colors (Dim, Calming Palette)
    static let lifeDeckPrimary = Color.hex("3B6BA5") // Primary Blue - trust and clarity
    static let lifeDeckSecondary = Color.hex("3AA79D") // Secondary Teal - balance and vitality
    static let lifeDeckAccent = Color.hex("4CAF50") // Success/Highlights - soft green
    
    // MARK: - Background Colors (Dark Mode First)
    static let lifeDeckBackground = Color.hex("1E1E1E") // Dim near-black background
    static let lifeDeckCardBackground = Color.hex("2A2A2A") // Slightly lighter for contrast
    static let lifeDeckSurfaceBackground = Color.hex("2A2A2A") // Same as card for consistency
    
    // MARK: - Text Colors
    static let lifeDeckTextPrimary = Color.hex("F2F2F2") // Off-white, not harsh
    static let lifeDeckTextSecondary = Color.hex("9A9A9A") // Dimmed gray
    static let lifeDeckTextTertiary = Color.hex("6A6A6A") // Darker gray for subtle text
    
    // MARK: - Domain Colors (Following Design Spec)
    static let lifeDeckHealth = Color.hex("4CAF50") // Health = 🏃 (muted green)
    static let lifeDeckFinance = Color.hex("FFB84D") // Finance = 💰 (muted amber)
    static let lifeDeckProductivity = Color.hex("5C9BD5") // Productivity = ⏳ (calming blue)
    static let lifeDeckMindfulness = Color.hex("9C27B0") // Mindfulness = 🧘 (muted purple)
    
    // MARK: - Status Colors
    static let lifeDeckSuccess = Color.hex("4CAF50") // Soft green for streaks, goals
    static let lifeDeckWarning = Color.hex("FFB84D") // Muted amber for alerts, nudges
    static let lifeDeckError = Color.hex("F44336") // Subtle red for errors
    static let lifeDeckInfo = Color.hex("64B5F6") // Soft info blue
    
    // MARK: - Gradient Colors (Premium CTA)
    static let lifeDeckGradientStart = Color.hex("3B6BA5") // Primary Blue
    static let lifeDeckGradientEnd = Color.hex("3AA79D") // Secondary Teal
    
    // MARK: - Premium Colors
    static let lifeDeckPremiumGold = Color.hex("FFD700") // Premium gold accent
    static let lifeDeckPremiumGradientStart = Color.hex("3B6BA5") // Primary Blue for gradients
    static let lifeDeckPremiumGradientEnd = Color.hex("3AA79D") // Secondary Teal for gradients
    
    // MARK: - Interactive Elements
    static let lifeDeckCardBorder = Color.hex("3A3A3A") // Subtle border color
    static let lifeDeckSeparator = Color.hex("333333") // Divider lines
    
    // MARK: - Utility Methods
    
    /// Create color from hex string
    static func hex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
    
    /// Get domain color for a life domain
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .health: return .lifeDeckHealth
        case .finance: return .lifeDeckFinance
        case .productivity: return .lifeDeckProductivity
        case .mindfulness: return .lifeDeckMindfulness
        }
    }
    
    /// Create a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
    
    /// Create a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return Color(UIColor(self).darkened(by: percentage))
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    /// Create UIColor from hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
    
    /// Get hex string representation
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Create a darker version of the color
    func darkened(by percentage: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: max(b - percentage, 0), alpha: a)
        }
        return self
    }
    
    /// Create a lighter version of the color
    func lightened(by percentage: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: min(b + percentage, 1), alpha: a)
        }
        return self
    }
}

// MARK: - Gradient Helpers
extension LinearGradient {
    /// Primary brand gradient
    static let lifeDeckPrimary = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckGradientStart, Color.lifeDeckGradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let success = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckSuccess, Color.lifeDeckSuccess.darker(by: 0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Health domain gradient
    static let health = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckHealth, Color.lifeDeckHealth.darker(by: 0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Finance domain gradient
    static let finance = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckFinance, Color.lifeDeckFinance.darker(by: 0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Productivity domain gradient
    static let productivity = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckProductivity, Color.lifeDeckProductivity.darker(by: 0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Mindfulness domain gradient
    static let mindfulness = LinearGradient(
        gradient: Gradient(colors: [Color.lifeDeckMindfulness, Color.lifeDeckMindfulness.darker(by: 0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Create gradient for domain
    static func forDomain(_ domain: LifeDomain) -> LinearGradient {
        switch domain {
        case .health: return .health
        case .finance: return .finance
        case .productivity: return .productivity
        case .mindfulness: return .mindfulness
        }
    }
}

// MARK: - Shadow Styles
extension View {
    /// Apply LifeDeck card shadow
    func lifeDeckCardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    /// Apply LifeDeck subtle shadow
    func lifeDeckSubtleShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    /// Apply LifeDeck strong shadow
    func lifeDeckStrongShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Color Accessibility
extension Color {
    /// Check if color is light (for determining text color)
    var isLight: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.7
    }
    
    /// Get contrasting text color
    var contrastingTextColor: Color {
        return isLight ? .lifeDeckTextPrimary : .white
    }
}

// MARK: - Color Constants for Asset Catalog
/*
 Add these colors to your Assets.xcassets:
 
 LifeDeckPrimary: #4A90E2
 LifeDeckSecondary: #50E3C2
 LifeDeckAccent: #7B68EE
 LifeDeckBackground: #F9FAFB
 LifeDeckCardBackground: #FFFFFF
 LifeDeckSurfaceBackground: #F5F7FA
 LifeDeckTextPrimary: #1C1C1E
 LifeDeckTextSecondary: #6E6E73
 LifeDeckTextTertiary: #9B9B9B
 LifeDeckHealth: #FF6B6B
 LifeDeckFinance: #4ECDC4
 LifeDeckProductivity: #45B7D1
 LifeDeckMindfulness: #96CEB4
 LifeDeckSuccess: #27AE60
 LifeDeckWarning: #F39C12
 LifeDeckError: #E74C3C
 LifeDeckInfo: #3498DB
 LifeDeckGradientStart: #667eea
 LifeDeckGradientEnd: #764ba2
 LifeDeckPremiumGold: #FFD700
 LifeDeckPremiumSilver: #C0C0C0
 */
