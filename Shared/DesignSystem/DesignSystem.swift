import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors - Exact specs: #3B6BA5 (59,107,165)
        static let primary = Color(red: 59/255, green: 107/255, blue: 165/255) // #3B6BA5
        static let primaryLight = Color(red: 227/255, green: 242/255, blue: 253/255) // #E3F2FD
        static let primaryDark = Color(red: 13/255, green: 71/255, blue: 161/255) // #0D47A1
        
        // Secondary Colors - Exact specs: #3AA79D (58,167,157)
        static let secondary = Color(red: 58/255, green: 167/255, blue: 157/255) // #3AA79D
        static let secondaryLight = Color(red: 0.85, green: 0.95, blue: 0.94)
        static let secondaryDark = Color(red: 0.16, green: 0.48, blue: 0.45)
        
        // Domain Colors
        static let health = Color.red
        static let finance = Color.green
        static let productivity = Color.blue
        static let mindfulness = Color.purple
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Neutral Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let surface = Color(.systemBackground)
        static let surfaceVariant = Color(.secondarySystemBackground)
        
        // Text Colors
        static let text = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        
        // Status Colors
        static let active = Color.green
        static let inactive = Color.gray
        static let premium = Color.yellow
    }
    
    // MARK: - Typography
    struct Typography {
        // Font Family
        static let fontFamily = "SF Pro"
        
        // Font Sizes
        static let largeTitle: Font = .largeTitle.weight(.bold)
        static let title1: Font = .title.weight(.bold)
        static let title2: Font = .title2.weight(.semibold)
        static let title3: Font = .title3.weight(.semibold)
        static let headline: Font = .headline.weight(.semibold)
        static let subheadline: Font = .subheadline.weight(.medium)
        static let body: Font = .body
        static let callout: Font = .callout
        static let footnote: Font = .footnote
        static let caption1: Font = .caption
        static let caption2: Font = .caption2.weight(.medium)
        
        // Custom Styles
        static let cardTitle: Font = .headline.weight(.semibold)
        static let cardSubtitle: Font = .subheadline.weight(.medium)
        static let buttonText: Font = .headline.weight(.semibold)
        static let statValue: Font = .title.weight(.bold)
        static let statLabel: Font = .caption.weight(.medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Component-specific spacing
        static let cardPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 12
        static let sectionSpacing: CGFloat = 24
        static let contentPadding: CGFloat = 20
        static let buttonHeight: CGFloat = 50
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 16
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = Shadow(
            color: .black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let large = Shadow(
            color: .black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        
        // Specific animations
        static let cardSwipe = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let modal = SwiftUI.Animation.easeInOut(duration: 0.4)
    }
    
    // MARK: - Gradients
    struct Gradients {
        static let primary = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.primaryDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let secondary = LinearGradient(
            gradient: Gradient(colors: [Colors.secondary, Colors.secondaryDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let background = LinearGradient(
            gradient: Gradient(colors: [Colors.background, Colors.secondaryBackground]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let card = LinearGradient(
            gradient: Gradient(colors: [Colors.surface, Colors.surfaceVariant]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Spacing.cornerRadius)
            .shadow(color: DesignSystem.Shadows.medium.color, radius: DesignSystem.Shadows.medium.radius, x: DesignSystem.Shadows.medium.x, y: DesignSystem.Shadows.medium.y)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.buttonText)
            .foregroundColor(.white)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.Spacing.cornerRadius)
            .frame(height: DesignSystem.Spacing.buttonHeight)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.buttonText)
            .foregroundColor(DesignSystem.Colors.primary)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .cornerRadius(DesignSystem.Spacing.cornerRadius)
            .frame(height: DesignSystem.Spacing.buttonHeight)
    }
}

// MARK: - Domain Color Extensions
extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .health:
            return DesignSystem.Colors.health
        case .finance:
            return DesignSystem.Colors.finance
        case .productivity:
            return DesignSystem.Colors.productivity
        case .mindfulness:
            return DesignSystem.Colors.mindfulness
        }
    }
}