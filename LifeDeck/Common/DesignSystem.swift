import SwiftUI
import UIKit

// MARK: - iOS Design System

/// Responsive design system optimized for all iOS devices
struct DesignSystem {
    
    // MARK: - Device Detection
    
    static var deviceType: DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenSize = max(screenWidth, screenHeight)
        
        switch screenSize {
        case ...667: return .compact // iPhone SE, iPhone 8
        case 668...736: return .regular // iPhone 8 Plus
        case 737...896: return .large // iPhone 11, XR, 12/13 mini, 14
        case 897...926: return .extraLarge // iPhone 12/13/14/15 Pro, 15
        case 927...: return .max // iPhone 12/13/14/15 Pro Max, Plus
        default: return .regular
        }
    }
    
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return false }
        return window.safeAreaInsets.top > 20
    }
}

enum DeviceType: CaseIterable {
    case compact    // iPhone SE, 8
    case regular    // iPhone 8 Plus
    case large      // iPhone 11, XR, 12 mini
    case extraLarge // iPhone 12/13/14/15 Pro
    case max        // iPhone Pro Max, Plus
}

// MARK: - Spacing System

extension DesignSystem {
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Device-responsive spacing
        static var cardPadding: CGFloat {
            switch deviceType {
            case .compact: return md
            case .regular: return md
            case .large: return lg
            case .extraLarge: return lg
            case .max: return xl
            }
        }
        
        static var screenHorizontal: CGFloat {
            isIPad ? xl : cardPadding
        }
        
        static var betweenSections: CGFloat {
            switch deviceType {
            case .compact: return lg
            case .regular: return lg
            case .large: return xl
            case .extraLarge: return xl
            case .max: return xxl
            }
        }
    }
}

// MARK: - Typography System

extension DesignSystem {
    
    struct Typography {
        // Responsive font sizes
        static var largeTitle: Font {
            switch deviceType {
            case .compact: return .system(size: 28, weight: .bold, design: .rounded)
            case .regular: return .system(size: 32, weight: .bold, design: .rounded)
            case .large, .extraLarge: return .system(size: 34, weight: .bold, design: .rounded)
            case .max: return .system(size: 36, weight: .bold, design: .rounded)
            }
        }
        
        static var title: Font {
            switch deviceType {
            case .compact: return .system(size: 22, weight: .bold, design: .rounded)
            case .regular: return .system(size: 24, weight: .bold, design: .rounded)
            case .large, .extraLarge: return .system(size: 26, weight: .bold, design: .rounded)
            case .max: return .system(size: 28, weight: .bold, design: .rounded)
            }
        }
        
        static var headline: Font {
            switch deviceType {
            case .compact: return .system(size: 18, weight: .semibold, design: .rounded)
            case .regular: return .system(size: 20, weight: .semibold, design: .rounded)
            case .large, .extraLarge: return .system(size: 22, weight: .semibold, design: .rounded)
            case .max: return .system(size: 24, weight: .semibold, design: .rounded)
            }
        }
        
        static var body: Font {
            switch deviceType {
            case .compact: return .system(size: 16, weight: .regular, design: .default)
            case .regular: return .system(size: 17, weight: .regular, design: .default)
            default: return .system(size: 17, weight: .regular, design: .default)
            }
        }
        
        static var callout: Font {
            .system(size: 16, weight: .medium, design: .default)
        }
        
        static var caption: Font {
            switch deviceType {
            case .compact: return .system(size: 11, weight: .medium, design: .default)
            default: return .system(size: 12, weight: .medium, design: .default)
            }
        }
    }
}

// MARK: - Layout System

extension DesignSystem {
    
    struct Layout {
        // Card dimensions
        static var cardWidth: CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            let horizontalPadding = Spacing.screenHorizontal * 2
            return min(screenWidth - horizontalPadding, 400)
        }
        
        static var cardHeight: CGFloat {
            switch deviceType {
            case .compact: return 420
            case .regular: return 450
            case .large: return 480
            case .extraLarge: return 500
            case .max: return 520
            }
        }
        
        // Grid columns
        static var gridColumns: Int {
            switch deviceType {
            case .compact: return 1
            case .regular: return 2
            default: return isIPad ? 3 : 2
            }
        }
        
        // Tab bar height
        static var tabBarHeight: CGFloat {
            hasNotch ? 83 : 49
        }
        
        // Navigation bar height
        static var navigationBarHeight: CGFloat {
            hasNotch ? 96 : 64
        }
        
        // Safe area compensation
        static var topSafeArea: CGFloat {
            UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.safeAreaInsets.top ?? 0
        }
        
        static var bottomSafeArea: CGFloat {
            UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.safeAreaInsets.bottom ?? 0
        }
    }
}

// MARK: - Animation System

extension DesignSystem {
    
    struct Animation {
        static let springDefault = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let springGentle = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.9)
        
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.25)
        
        // iOS-native timings
        static let quickTap = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standardTransition = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let slowReveal = SwiftUI.Animation.easeOut(duration: 0.5)
    }
}

// MARK: - View Extensions for Responsive Design

extension View {
    
    /// Apply responsive horizontal padding
    func responsiveHorizontalPadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
    }
    
    /// Apply responsive card padding
    func responsiveCardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }
    
    /// Apply safe area top padding only when needed
    func conditionalTopSafeArea() -> some View {
        self.padding(.top, DesignSystem.hasNotch ? 0 : DesignSystem.Spacing.sm)
    }
    
    /// Make view fill screen width with responsive padding
    func fillWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    /// Apply device-appropriate corner radius
    func adaptiveCornerRadius(_ base: CGFloat = 12) -> some View {
        let radius = DesignSystem.deviceType == .compact ? base * 0.8 : base
        return self.cornerRadius(radius)
    }
    
    /// Apply iOS-native shadow
    func iosNativeShadow(elevation: ShadowElevation = .medium) -> some View {
        self.shadow(
            color: elevation.color,
            radius: elevation.radius,
            x: elevation.x,
            y: elevation.y
        )
    }
}

// MARK: - Shadow System

enum ShadowElevation {
    case none, low, medium, high, extreme
    
    var color: Color {
        Color.black.opacity(opacity)
    }
    
    private var opacity: Double {
        switch self {
        case .none: return 0
        case .low: return 0.08
        case .medium: return 0.12
        case .high: return 0.16
        case .extreme: return 0.24
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .low: return 2
        case .medium: return 8
        case .high: return 16
        case .extreme: return 24
        }
    }
    
    var x: CGFloat { 0 }
    
    var y: CGFloat {
        switch self {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 4
        case .extreme: return 8
        }
    }
}

// MARK: - iOS Native Button Styles

struct iOSButtonStyle: ButtonStyle {
    let style: Style
    
    enum Style {
        case primary, secondary, destructive, plain
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .lifeDeckPrimary
            case .secondary: return .lifeDeckCardBackground
            case .destructive: return .lifeDeckError
            case .plain: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return .lifeDeckTextPrimary
            case .secondary: return .lifeDeckPrimary
            case .plain: return .lifeDeckPrimary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary, .destructive, .plain: return .clear
            case .secondary: return .lifeDeckPrimary
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.callout)
            .foregroundColor(style.foregroundColor)
            .fillWidth()
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 10 : 12)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 10 : 12)
                            .stroke(style.borderColor, lineWidth: style == .secondary ? 2 : 0)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.quickTap, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == iOSButtonStyle {
    static var iosPrimary: iOSButtonStyle { iOSButtonStyle(style: .primary) }
    static var iosSecondary: iOSButtonStyle { iOSButtonStyle(style: .secondary) }
    static var iosDestructive: iOSButtonStyle { iOSButtonStyle(style: .destructive) }
    static var iosPlain: iOSButtonStyle { iOSButtonStyle(style: .plain) }
}
