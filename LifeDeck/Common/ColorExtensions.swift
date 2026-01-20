import SwiftUI

// MARK: - Color Extensions
extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .health: return .red
        case .finance: return .green
        case .productivity: return .blue
        case .mindfulness: return .purple
        }
    }
    
    // Additional missing colors
    static let textTertiary = Color.gray.opacity(0.6)
}