import SwiftUI
import UIKit

// MARK: - iOS Design System

/// Responsive design system optimized for all iOS devices
enum DesignSystem {
    
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
    
    enum DeviceType: CaseIterable {
        case compact    // iPhone SE, 8
        case regular    // iPhone 8 Plus
        case large      // iPhone 11, XR, 12 mini
        case extraLarge // iPhone 12/13/14/15 Pro
        case max        // iPhone Pro Max, Plus
    }
}

// MARK: - Spacing System

extension DesignSystem {
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // Device-responsive spacing
        static var cardPadding: CGFloat {
            switch DesignSystem.deviceType {
            case .compact: return md
            case .regular: return md
            case .large: return lg
            case .extraLarge: return lg
            case .max: return xl
            }
        }
        
        static var screenHorizontal: CGFloat {
            DesignSystem.isIPad ? xl : cardPadding
        }
        
        static var betweenSections: CGFloat {
            switch DesignSystem.deviceType {
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
    
    enum Typography {
        // Responsive font sizes
        static var largeTitle: Font {
            switch DesignSystem.deviceType {
            case .compact: return .system(size: 28, weight: .bold, design: .rounded)
            case .regular: return .system(size: 32, weight: .bold, design: .rounded)
            case .large, .extraLarge: return .system(size: 34, weight: .bold, design: .rounded)
            case .max: return .system(size: 36, weight: .bold, design: .rounded)
            }
        }
        
        static var title: Font {
            switch DesignSystem.deviceType {
            case .compact: return .system(size: 22, weight: .bold, design: .rounded)
            case .regular: return .system(size: 24, weight: .bold, design: .rounded)
            case .large, .extraLarge: return .system(size: 26, weight: .bold, design: .rounded)
            case .max: return .system(size: 28, weight: .bold, design: .rounded)
            }
        }
        
        static var headline: Font {
            switch DesignSystem.deviceType {
            case .compact: return .system(size: 18, weight: .semibold, design: .rounded)
            case .regular: return .system(size: 20, weight: .semibold, design: .rounded)
            case .large, .extraLarge: return .system(size: 22, weight: .semibold, design: .rounded)
            case .max: return .system(size: 24, weight: .semibold, design: .rounded)
            }
        }
        
        static var body: Font {
            switch DesignSystem.deviceType {
            case .compact: return .system(size: 16, weight: .regular, design: .default)
            case .regular: return .system(size: 17, weight: .regular, design: .default)
            default: return .system(size: 17, weight: .regular, design: .default)
            }
        }
        
        static var callout: Font {
            .system(size: 16, weight: .medium, design: .default)
        }
        
        static var caption: Font {
            switch DesignSystem.deviceType {
            case .compact: return .system(size: 11, weight: .medium, design: .default)
            default: return .system(size: 12, weight: .medium, design: .default)
            }
        }
    }
}

// MARK: - Layout System

extension DesignSystem {
    
    enum Layout {
        // Card dimensions
        static var cardWidth: CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            let horizontalPadding = DesignSystem.Spacing.screenHorizontal * 2
            return min(screenWidth - horizontalPadding, 400)
        }
        
        static var cardHeight: CGFloat {
            switch DesignSystem.deviceType {
            case .compact: return 420
            case .regular: return 450
            case .large: return 480
            case .extraLarge: return 500
            case .max: return 520
            }
        }
        
        // Grid columns
        static var gridColumns: Int {
            switch DesignSystem.deviceType {
            case .compact: return 1
            case .regular: return 2
            default: return DesignSystem.isIPad ? 3 : 2
            }
        }
        
        // Tab bar height
        static var tabBarHeight: CGFloat {
            DesignSystem.hasNotch ? 83 : 49
        }
        
        // Navigation bar height
        static var navigationBarHeight: CGFloat {
            DesignSystem.hasNotch ? 96 : 64
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
    
    enum Animation {
        // Card animations
        static let cardSwipe = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let cardShuffle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let cardFlip = SwiftUI.Animation.easeInOut(duration: 0.4)
        
        // Premium effects
        static let premiumGlow = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let premiumBounce = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let confettiCelebration = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.5)
        
        // Standard animations
        static let springDefault = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let springGentle = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.9)
        
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.25)
        
        // iOS-native timings
        static let quickTap = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standardTransition = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let slowReveal = SwiftUI.Animation.easeOut(duration: 0.5)
        
        // Micro-interactions
        static let hoverEffect = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let pulseEffect = SwiftUI.Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        static let streakProgress = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
}

// MARK: - Premium Effects System

extension DesignSystem {
    
    enum PremiumEffects {
        
        /// Glow intensity for premium elements
        static let glowRadius: CGFloat = 8
        static let glowOpacity: Double = 0.6
        
        /// Premium button glow
        static func premiumButtonGlow(_ isPressed: Bool = false) -> some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient.lifeDeckPrimary)
                .blur(radius: glowRadius)
                .opacity(isPressed ? glowOpacity * 0.5 : glowOpacity)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        
        /// Premium card border glow
        static func premiumCardGlow() -> some View {
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient.lifeDeckPrimary, lineWidth: 2)
                .blur(radius: 4)
                .opacity(0.8)
        }
        
        /// Streak progress glow effect
        static func streakGlow(_ progress: Double) -> some View {
            Circle()
                .fill(Color.lifeDeckSuccess)
                .blur(radius: 6)
                .opacity(0.6)
                .scaleEffect(CGSize(width: progress, height: progress))
        }
    }
}

// MARK: - Card Swipe Effects

extension DesignSystem {
    
    enum CardEffects {
        
        /// Card swipe direction colors
        static func swipeColor(for direction: SwipeDirection) -> Color {
            switch direction {
            case .right: return .lifeDeckSuccess // Completed
            case .left: return .lifeDeckError // Dismissed  
            case .down: return .lifeDeckWarning // Snoozed
            case .up: return .lifeDeckInfo // Details
            }
        }
        
        /// Card border effect based on swipe
        static func swipeBorder(for direction: SwipeDirection, intensity: CGFloat) -> some View {
            RoundedRectangle(cornerRadius: 24)
                .stroke(swipeColor(for: direction), lineWidth: 3)
                .opacity(intensity)
                .blur(radius: intensity * 2)
        }
    }
}

enum SwipeDirection {
    case left, right, up, down
}

// MARK: - Domain-Specific Effects

extension DesignSystem {
    
    enum DomainEffects {
        
        /// Get domain-specific gradient
        static func domainGradient(for domain: LifeDomain) -> LinearGradient {
            switch domain {
            case .health:
                return LinearGradient(
                    gradient: Gradient(colors: [.lifeDeckHealth, .lifeDeckHealth.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .finance:
                return LinearGradient(
                    gradient: Gradient(colors: [.lifeDeckFinance, .lifeDeckFinance.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .productivity:
                return LinearGradient(
                    gradient: Gradient(colors: [.lifeDeckProductivity, .lifeDeckProductivity.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .mindfulness:
                return LinearGradient(
                    gradient: Gradient(colors: [.lifeDeckMindfulness, .lifeDeckMindfulness.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        /// Domain-specific icon with glow
        static func domainIcon(for domain: LifeDomain, size: CGFloat = 24) -> some View {
            Image(systemName: domain.icon)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundColor(Color.forDomain(domain))
                .shadow(color: Color.forDomain(domain).opacity(0.5), radius: 4, x: 0, y: 2)
        }
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
    
    // MARK: - Premium/Free Tier Visual Distinctions
    
    /// Apply premium glow effect
    func premiumGlow(_ isActive: Bool = true) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient.lifeDeckPrimary)
                .blur(radius: 8)
                .opacity(isActive ? 0.3 : 0)
                .animation(DesignSystem.Animation.premiumGlow, value: isActive)
        )
    }
    
    /// Apply locked/premium overlay
    func premiumLocked(_ isLocked: Bool) -> some View {
        self.overlay(
            Group {
                if isLocked {
                    ZStack {
                        // Blur overlay
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.lifeDeckCardBackground.opacity(0.8))
                            .blur(radius: 2)
                        
                        // Lock icon with glow
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "lock.fill")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(.lifeDeckPremiumGold)
                                .shadow(color: .lifeDeckPremiumGold.opacity(0.6), radius: 4)
                            
                            Text("Premium")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(.lifeDeckTextSecondary)
                        }
                    }
                    .animation(DesignSystem.Animation.slowReveal, value: isLocked)
                }
            }
        )
    }
    
    /// Apply free tier limitation styling
    func freeTierLimited(_ isLimited: Bool) -> some View {
        self.overlay(
            Group {
                if isLimited {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.lifeDeckWarning.opacity(0.5), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.lifeDeckWarning.opacity(0.05))
                        )
                }
            }
        )
        .saturation(isLimited ? 0.6 : 1.0)
        .brightness(isLimited ? -0.1 : 0)
    }
    
    /// Apply premium tier enhancement styling
    func premiumEnhanced(_ isEnhanced: Bool) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient.lifeDeckPrimary.opacity(0.1))
                    .opacity(isEnhanced ? 1 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient.lifeDeckPrimary, lineWidth: isEnhanced ? 1 : 0)
                    .opacity(isEnhanced ? 0.8 : 0)
            )
            .scaleEffect(isEnhanced ? 1.02 : 1.0)
            .animation(DesignSystem.Animation.premiumBounce, value: isEnhanced)
    }
    
    /// Apply upgrade CTA bounce animation
    func upgradeBounce(_ shouldBounce: Bool) -> some View {
        self
            .scaleEffect(shouldBounce ? 1.05 : 1.0)
            .animation(
                shouldBounce ? 
                    DesignSystem.Animation.premiumBounce.repeatCount(3, autoreverses: true) :
                    .none,
                value: shouldBounce
            )
    }
    
    /// Apply card swipe visual feedback
    func cardSwipeFeedback(direction: SwipeDirection?, intensity: CGFloat = 0) -> some View {
        self.overlay(
            Group {
                if let direction = direction, intensity > 0 {
                    DesignSystem.CardEffects.swipeBorder(for: direction, intensity: intensity)
                }
            }
        )
    }
    
    /// Apply celebration confetti effect
    func confettiCelebration(_ isActive: Bool) -> some View {
        self.background(
            Group {
                if isActive {
                    // Simple celebration effect - can be enhanced with particles
                    Circle()
                        .fill(Color.lifeDeckSuccess.opacity(0.3))
                        .scaleEffect(isActive ? 2.0 : 0.1)
                        .opacity(isActive ? 0.0 : 1.0)
                        .animation(DesignSystem.Animation.confettiCelebration, value: isActive)
                }
            }
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
