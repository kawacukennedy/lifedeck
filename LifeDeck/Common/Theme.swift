import SwiftUI

// MARK: - Theme System
enum AppTheme: String, CaseIterable {
    case light, dark, highContrast
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .highContrast: return "High Contrast"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .light
    
    init() {
        loadThemePreference()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveThemePreference(theme)
    }
    
    private func loadThemePreference() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "light"
        currentTheme = AppTheme(rawValue: savedTheme) ?? .light
    }
    
    private func saveThemePreference(_ theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
}