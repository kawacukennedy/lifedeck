import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors (Updated to match exact specs)
    struct Colors {
        // Primary colors from specs
        static let primary50 = Color(red: 227/255, green: 242/255, blue: 253/255) // #E3F2FD
        static let primary500 = Color(red: 33/255, green: 150/255, blue: 243/255) // #2196F3
        static let primary900 = Color(red: 13/255, green: 71/255, blue: 161/255) // #0D47A1
        
        // Main primary colors
        static let primary = primary500
        static let primaryBlue = primary500
        
        // Secondary colors
        static let secondaryTeal = Color(red: 58/255, green: 167/255, blue: 157/255) // #3AA79D
        static let secondary = secondaryTeal
        
        // Semantic colors from specs
        static let success = Color(red: 76/255, green: 175/255, blue: 80/255) // #4CAF50
        static let successLight = Color(red: 76/255, green: 175/255, blue: 80/255) // #4CAF50
        static let successDark = Color(red: 56/255, green: 126/255, blue: 60/255) // #388E3C
        
        static let warning = Color(red: 255/255, green: 184/255, blue: 77/255) // #FFB84D
        static let warningLight = Color(red: 255/255, green: 184/255, blue: 77/255) // #FFB84D
        static let warningDark = Color(red: 251/255, green: 140/255, blue: 0/255) // #FB8C00
        
        static let error = Color(red: 229/255, green: 115/255, blue: 115/255) // #E57373
        static let errorLight = Color(red: 229/255, green: 115/255, blue: 115/255) // #E57373
        static let errorDark = Color(red: 198/255, green: 40/255, blue: 40/255) // #C62828
        
        static let info = Color(red: 100/255, green: 181/255, blue: 246/255) // #64B5F6
        static let infoLight = Color(red: 100/255, green: 181/255, blue: 246/255) // #64B5F6
        static let infoDark = Color(red: 25/255, green: 118/255, blue: 210/255) // #1976D2
        
        // Theme colors from specs
        static let lightBackground = Color.white // #FFFFFF
        static let lightText = Color(red: 33/255, green: 33/255, blue: 33/255) // #212121
        static let lightPrimary = Color(red: 33/255, green: 150/255, blue: 243/255) // #2196F3
        
        static let darkBackground = Color(red: 18/255, green: 18/255, blue: 18/255) // #121212
        static let darkText = Color(red: 224/255, green: 224/255, blue: 224/255) // #E0E0E0
        static let darkPrimary = Color(red: 33/255, green: 150/255, blue: 243/255) // #2196F3
        
        static let highContrastBackground = Color.black // #000000
        static let highContrastText = Color.white // #FFFFFF
        static let highContrastPrimary = Color(red: 255/255, green: 235/255, blue: 59/255) // #FFEB3B
        
        // Background colors from specs
        static let backgroundDark = Color(red: 30/255, green: 30/255, blue: 30/255) // #1E1E1E
        static let cardSurface = Color(red: 42/255, green: 42/255, blue: 42/255) // #2A2A2A
        
        // System colors (will adapt to light/dark mode)
        static let background = Color.primary.opacity(0.05)
        static let surface = Color.primary.opacity(0.08)
        static let secondaryBackground = Color.gray.opacity(0.1)
        static let text = Color.primary
        static let textSecondary = Color.secondary
        
        // Additional colors
        static let textTertiary = Color.gray.opacity(0.6)
        
        // Premium colors
        static let premium = Color.orange
    }
    
    // MARK: - Typography (Updated to match SF Pro scale from specs)
    struct Typography {
        // Type scale from specs
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 24, weight: .semibold)
        static let title3 = Font.title3.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let bodyLarge = Font.system(size: 18, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .regular)
        static let bodySmall = Font.system(size: 14, weight: .regular)
        static let caption1 = Font.caption
        static let caption2 = Font.caption2
        
        // Additional typography styles
        static let buttonText = Font.headline.weight(.medium)
        static let callout = Font.callout
    }
    
    // MARK: - Spacing (Updated to match specs - base unit: 8px)
    struct Spacing {
        static let baseUnit: CGFloat = 8
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        static let fourxl: CGFloat = 128
        
        // Specific spacing constants
        static let cardPadding: CGFloat = 16
        static let contentPadding: CGFloat = 20
        static let buttonHeight: CGFloat = 56
    }
    
    // MARK: - Corner Radius (Updated to match specs)
    struct CornerRadius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
        // Backward compatibility
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    // MARK: - Border Width (Updated to match specs)
    struct BorderWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
        static let thick: CGFloat = 3
    }
    
    // MARK: - Shadows (Updated to match specs)
    struct Shadows {
        struct level1 {
            static let color = Color.black.opacity(0.2)
            static let radius: CGFloat = 4
            static let x: CGFloat = 0
            static let y: CGFloat = 2
        }
        
        struct level2 {
            static let color = Color.black.opacity(0.3)
            static let radius: CGFloat = 12
            static let x: CGFloat = 0
            static let y: CGFloat = 6
        }
        
        struct level3 {
            static let color = Color.black.opacity(0.19)
            static let radius: CGFloat = 20
            static let x: CGFloat = 0
            static let y: CGFloat = 10
        }
        
        struct medium {
            static let color = Color.black.opacity(0.25)
            static let radius: CGFloat = 8
            static let x: CGFloat = 0
            static let y: CGFloat = 4
        }
    }
    
    // MARK: - Motion and Animation (Updated to match specs)
    struct Animation {
        static let instant = SwiftUI.Animation.easeInOut(duration: 0)
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let normal = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slower = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        static let spring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        
        // Easing functions from specs
        static let linear = SwiftUI.Animation.linear(duration: 0.2)
        static let easeIn = SwiftUI.Animation.easeIn(duration: 0.2)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.2)
    }
    
    // MARK: - Z-Index Scale (Updated to match specs)
    struct ZIndex {
        static let base: CGFloat = 0
        static let dropdown: CGFloat = 1000
        static let modal: CGFloat = 1050
        static let tooltip: CGFloat = 1070
        static let toast: CGFloat = 1080
    }
}

// MARK: - View Modifiers
extension View {
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.lg)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.primary, lineWidth: DesignSystem.BorderWidth.thin)
            )
    }
    
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .shadow(color: DesignSystem.Shadows.level1.color, 
                   radius: DesignSystem.Shadows.level1.radius, 
                   x: DesignSystem.Shadows.level1.x, 
                   y: DesignSystem.Shadows.level1.y)
    }
}