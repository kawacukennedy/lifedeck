import SwiftUI

// MARK: - Keyboard Shortcuts Manager

struct KeyboardShortcutsManager: ViewModifier {
    @State private var currentShortcut: KeyboardShortcut?
    @EnvironmentObject private var user: User
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    // Keyboard shortcuts mapping
    private let shortcuts: [KeyEquivalent: KeyboardShortcut] = [
        .d: KeyboardShortcut("D", modifiers: [.command]), // Dashboard
        .c: KeyboardShortcut("C", modifiers: [.command]), // Cards/Deck
        .a: KeyboardShortcut("A", modifiers: [.command]), // Analytics
        .p: KeyboardShortcut("P", modifiers: [.command]), // Profile
        .r: KeyboardShortcut("R", modifiers: [.command]), // Refresh
        .space: KeyboardShortcut(.space, modifiers: []), // Complete card
        .s: KeyboardShortcut("S", modifiers: [.command]), // Snooze card
        .escape: KeyboardShortcut(.escape), // Cancel/Dismiss
        .rightArrow: KeyboardShortcut(.rightArrow), // Next/Complete
        .leftArrow: KeyboardShortcut(.leftArrow), // Previous/Dismiss
        .downArrow: KeyboardShortcut(.downArrow), // Snooze
        .upArrow: KeyboardShortcut(.upArrow), // Details
        .return: KeyboardShortcut(.return), // Confirm action
        .1: KeyboardShortcut("1"), // Health domain
        .2: KeyboardShortcut("2"), // Finance domain
        .3: KeyboardShortcut("3"), // Productivity domain
        .4: KeyboardShortcut("4"), // Mindfulness domain
    ]
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                // Keyboard is visible - user might want shortcuts
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                // Keyboard is hidden
            }
            .background(
                KeyboardShortcutHandler(
                    shortcuts: shortcuts,
                    onShortcut: handleShortcut
                )
            )
    }
}

// MARK: - Keyboard Shortcut Handler

struct KeyboardShortcutHandler: UIViewRepresentable {
    let shortcuts: [KeyEquivalent: KeyboardShortcut]
    let onShortcut: (KeyboardShortcut) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Set up key command handling
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                setupKeyCommands(for: window, context: context)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
    
    private func setupKeyCommands(for window: UIWindow, context: Context) {
        window.makeKey()
        
        // This would require additional setup with UIResponder chain
        // For now, we'll provide the structure for keyboard shortcuts
    }
}

// MARK: - Keyboard Shortcuts Helper View

struct KeyboardShortcutsHelper: View {
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Introduction
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Keyboard Shortcuts")
                            .font(DesignSystem.Typography.largeTitle)
                        
                        Text("Navigate LifeDeck faster with these keyboard shortcuts")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Navigation shortcuts
                    ShortcutCategory(
                        title: "Navigation",
                        shortcuts: [
                            ShortcutItem(key: "⌘D", description: "Go to Dashboard"),
                            ShortcutItem(key: "⌘C", description: "Go to Cards"),
                            ShortcutItem(key: "⌘A", description: "Go to Analytics"),
                            ShortcutItem(key: "⌘P", description: "Go to Profile"),
                        ]
                    )
                    
                    // Card actions
                    ShortcutCategory(
                        title: "Card Actions",
                        shortcuts: [
                            ShortcutItem(key: "Space", description: "Complete current card"),
                            ShortcutItem(key: "⌘S", description: "Snooze current card"),
                            ShortcutItem(key: "→", description: "Complete/Next card"),
                            ShortcutItem(key: "←", description: "Dismiss/Previous card"),
                            ShortcutItem(key: "↓", description: "Snooze card"),
                            ShortcutItem(key: "↑", description: "Show card details"),
                            ShortcutItem(key: "⌘R", description: "Refresh cards"),
                        ]
                    )
                    
                    // Domain shortcuts
                    ShortcutCategory(
                        title: "Domain Quick Access",
                        shortcuts: [
                            ShortcutItem(key: "1", description: "Filter Health cards"),
                            ShortcutItem(key: "2", description: "Filter Finance cards"),
                            ShortcutItem(key: "3", description: "Filter Productivity cards"),
                            ShortcutItem(key: "4", description: "Filter Mindfulness cards"),
                        ]
                    )
                    
                    // General shortcuts
                    ShortcutCategory(
                        title: "General",
                        shortcuts: [
                            ShortcutItem(key: "Esc", description: "Cancel/Dismiss modal"),
                            ShortcutItem(key: "↩", description: "Confirm action"),
                            ShortcutItem(key: "⌘?", description: "Show this help"),
                        ]
                    )
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationTitle("Keyboard Shortcuts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Shortcut Components

struct ShortcutCategory: View {
    let title: String
    let shortcuts: [ShortcutItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(shortcuts) { shortcut in
                    shortcut
                }
            }
        }
    }
}

struct ShortcutItem: View, Identifiable {
    let id = UUID()
    let key: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Key indicator
            Text(key)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                )
            
            // Description
            Text(description)
                .font(DesignSystem.Typography.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Keyboard Shortcuts Button

struct KeyboardShortcutsButton: View {
    @State private var showingShortcuts = false
    
    var body: some View {
        Button {
            showingShortcuts = true
        } label: {
            Image(systemName: "keyboard")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .adaptiveModal(
            isPresented: showingShortcuts,
            onDismiss: { showingShortcuts = false }
        ) {
            KeyboardShortcutsHelper(isPresented: $showingShortcuts)
        }
    }
}

// MARK: - Extension for easier usage

extension View {
    func withKeyboardShortcuts() -> some View {
        modifier(KeyboardShortcutsManager())
    }
}

// MARK: - Supporting Types

enum KeyEquivalent: Hashable {
    case d, c, a, p, r, s, escape, return, space
    case rightArrow, leftArrow, upArrow, downArrow
    case one, two, three, four
    
    var character: Character {
        switch self {
        case .d: return "d"
        case .c: return "c"
        case .a: return "a"
        case .p: return "p"
        case .r: return "r"
        case .s: return "s"
        case .space: return " "
        case .return: return "\r"
        case .escape: return "\u{1B}"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        default: return ""
        }
    }
}

struct KeyboardShortcut {
    let key: KeyEquivalent
    let modifiers: EventModifiers
    
    init(_ key: String, modifiers: EventModifiers = []) {
        switch key.lowercased() {
        case "d": self.init(key: .d, modifiers: modifiers)
        case "c": self.init(key: .c, modifiers: modifiers)
        case "a": self.init(key: .a, modifiers: modifiers)
        case "p": self.init(key: .p, modifiers: modifiers)
        case "r": self.init(key: .r, modifiers: modifiers)
        case "s": self.init(key: .s, modifiers: modifiers)
        case "1": self.init(key: .one, modifiers: modifiers)
        case "2": self.init(key: .two, modifiers: modifiers)
        case "3": self.init(key: .three, modifiers: modifiers)
        case "4": self.init(key: .four, modifiers: modifiers)
        default: self.init(key: .space, modifiers: modifiers)
        }
    }
    
    init(_ character: Character, modifiers: EventModifiers = []) {
        switch character {
        case "d": self.init(key: .d, modifiers: modifiers)
        case "c": self.init(key: .c, modifiers: modifiers)
        case "a": self.init(key: .a, modifiers: modifiers)
        case "p": self.init(key: .p, modifiers: modifiers)
        case "r": self.init(key: .r, modifiers: modifiers)
        case "s": self.init(key: .s, modifiers: modifiers)
        case "1": self.init(key: .one, modifiers: modifiers)
        case "2": self.init(key: .two, modifiers: modifiers)
        case "3": self.init(key: .three, modifiers: modifiers)
        case "4": self.init(key: .four, modifiers: modifiers)
        default: self.init(key: .space, modifiers: modifiers)
        }
    }
    
    init(_ specialKey: SpecialKey) {
        switch specialKey {
        case .space: self.init(key: .space, modifiers: [])
        case .return: self.init(key: .return, modifiers: [])
        case .escape: self.init(key: .escape, modifiers: [])
        case .rightArrow: self.init(key: .rightArrow, modifiers: [])
        case .leftArrow: self.init(key: .leftArrow, modifiers: [])
        case .upArrow: self.init(key: .upArrow, modifiers: [])
        case .downArrow: self.init(key: .downArrow, modifiers: [])
        }
    }
    
    init(key: KeyEquivalent, modifiers: EventModifiers = []) {
        self.key = key
        self.modifiers = modifiers
    }
}

enum SpecialKey {
    case space, return, escape
    case rightArrow, leftArrow, upArrow, downArrow
}

enum EventModifiers: OptionSet {
    case command, control, option, shift
    
    static let command: EventModifiers = [.command]
    static let control: EventModifiers = [.control]
    static let option: EventModifiers = [.option]
    static let shift: EventModifiers = [.shift]
}

// MARK: - Preview

#Preview {
    VStack {
        Button("Show Shortcuts") {
            // Show keyboard shortcuts
        }
        .withKeyboardShortcuts()
        
        Text("Press ⌘? to see all shortcuts")
            .foregroundColor(.secondary)
    }
    .padding()
}