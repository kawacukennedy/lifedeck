import SwiftUI

// MARK: - Primary Button Style
struct LifeDeckPrimaryButtonStyle: ButtonStyle {
    let isDisabled: Bool
    
    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 200, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        isDisabled ? Color.gray :
                        (configuration.isPressed ? Color.lifeDeckPrimary.opacity(0.8) : Color.lifeDeckPrimary)
                    )
            )
            .lifeDeckCardShadow()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct LifeDeckSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundColor(.lifeDeckPrimary)
            .frame(minWidth: 200, minHeight: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.lifeDeckCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.lifeDeckPrimary, lineWidth: 2)
                    )
            )
            .lifeDeckSubtleShadow()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Action Button Style
struct LifeDeckCardActionButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .lifeDeckPrimary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(configuration.isPressed ? color.opacity(0.8) : color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Floating Action Button Style
struct LifeDeckFloatingActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.lifeDeckPrimary, Color.lifeDeckSecondary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .lifeDeckStrongShadow()
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Premium Button Style (with glow effect)
struct LifeDeckPremiumButtonStyle: ButtonStyle {
    @State private var isGlowing = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.lifeDeckTextPrimary)
            .frame(minWidth: 200, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.lifeDeckPremiumGradientStart,
                                Color.lifeDeckPremiumGradientEnd
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.lifeDeckTextPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
            .overlay(
                // Outer glow effect
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.lifeDeckPrimary.opacity(isGlowing ? 0.8 : 0.4), lineWidth: 2)
                    .blur(radius: isGlowing ? 8 : 4)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
            )
            .shadow(
                color: Color.lifeDeckPrimary.opacity(0.3),
                radius: isGlowing ? 12 : 6,
                x: 0,
                y: 0
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .onAppear {
                isGlowing = true
            }
    }
}

// MARK: - Destructive Button Style
struct LifeDeckDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 150, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(configuration.isPressed ? Color.lifeDeckError.opacity(0.8) : Color.lifeDeckError)
            )
            .lifeDeckSubtleShadow()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Compact Button Style
struct LifeDeckCompactButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .lifeDeckPrimary) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isPressed ? color.opacity(0.8) : color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Pill Button Style
struct LifeDeckPillButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let textColor: Color
    
    init(backgroundColor: Color = .lifeDeckSurfaceBackground, textColor: Color = .lifeDeckTextPrimary) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            )
            .overlay(
                Capsule()
                    .stroke(Color.lifeDeckTextTertiary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == LifeDeckPrimaryButtonStyle {
    static func lifeDeckPrimary(isDisabled: Bool = false) -> LifeDeckPrimaryButtonStyle {
        LifeDeckPrimaryButtonStyle(isDisabled: isDisabled)
    }
}

extension ButtonStyle where Self == LifeDeckSecondaryButtonStyle {
    static var lifeDeckSecondary: LifeDeckSecondaryButtonStyle {
        LifeDeckSecondaryButtonStyle()
    }
}

extension ButtonStyle where Self == LifeDeckCardActionButtonStyle {
    static func lifeDeckCardAction(color: Color = .lifeDeckPrimary) -> LifeDeckCardActionButtonStyle {
        LifeDeckCardActionButtonStyle(color: color)
    }
}

extension ButtonStyle where Self == LifeDeckFloatingActionButtonStyle {
    static var lifeDeckFloatingAction: LifeDeckFloatingActionButtonStyle {
        LifeDeckFloatingActionButtonStyle()
    }
}

extension ButtonStyle where Self == LifeDeckPremiumButtonStyle {
    static var lifeDeckPremium: LifeDeckPremiumButtonStyle {
        LifeDeckPremiumButtonStyle()
    }
}

extension ButtonStyle where Self == LifeDeckDestructiveButtonStyle {
    static var lifeDeckDestructive: LifeDeckDestructiveButtonStyle {
        LifeDeckDestructiveButtonStyle()
    }
}

extension ButtonStyle where Self == LifeDeckCompactButtonStyle {
    static func lifeDeckCompact(color: Color = .lifeDeckPrimary) -> LifeDeckCompactButtonStyle {
        LifeDeckCompactButtonStyle(color: color)
    }
}

extension ButtonStyle where Self == LifeDeckPillButtonStyle {
    static func lifeDeckPill(backgroundColor: Color = .lifeDeckSurfaceBackground, textColor: Color = .lifeDeckTextPrimary) -> LifeDeckPillButtonStyle {
        LifeDeckPillButtonStyle(backgroundColor: backgroundColor, textColor: textColor)
    }
}
