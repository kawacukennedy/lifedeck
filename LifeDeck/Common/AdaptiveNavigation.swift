import SwiftUI

// MARK: - Adaptive Navigation System

struct AdaptiveNavigationView<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ViewBuilder let content: Content
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad Layout - Use NavigationSplitView
            NavigationSplitView {
                // Sidebar
                List(SidebarSection.allCases, id: \.self, selection: .constant(.dashboard)) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.systemImage)
                    }
                }
                .navigationTitle("LifeDeck")
                .listStyle(.sidebar)
            } detail: {
                content
            }
        } else {
            // iPhone Layout - Use NavigationStack
            NavigationStack {
                content
            }
        }
    }
}

// MARK: - Sidebar Navigation for iPad

struct SidebarView: View {
    @State private var selectedSection: SidebarSection = .dashboard
    
    enum SidebarSection: String, CaseIterable {
        case dashboard = "Dashboard"
        case deck = "Daily Deck"
        case analytics = "Analytics"
        case profile = "Profile"
        
        var systemImage: String {
            switch self {
            case .dashboard: return "house.fill"
            case .deck: return "rectangle.stack.fill"
            case .analytics: return "chart.bar.fill"
            case .profile: return "person.fill"
            }
        }
        
        var destination: some View {
            switch self {
            case .dashboard:
                SimpleDashboardView(user: loadUser())
            case .deck:
                DeckView(user: loadUser())
            case .analytics:
                SimpleAnalyticsView(user: loadUser())
            case .profile:
                SimpleProfileView(user: loadUser())
            }
        }
    }
    
    var body: some View {
        List(SidebarSection.allCases, id: \.self, selection: $selectedSection) { section in
            NavigationLink(value: section) {
                Label(section.rawValue, systemImage: section.systemImage)
            }
        }
        .navigationTitle("LifeDeck")
        .listStyle(.sidebar)
    }
}

// MARK: - Adaptive Container View

struct AdaptiveContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ViewBuilder let content: Content
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad: Use horizontal space efficiently
            HStack(spacing: 20) {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // iPhone: Vertical layout
            VStack(spacing: 15) {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Adaptive Modal Presentation

struct AdaptiveModal<Content: View>: ViewModifier {
    let isPresented: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            // iPad: Use popover
            content
                .popover(isPresented: isPresented) {
                    self.content
                        .frame(width: 400, height: 600)
                        .padding()
                }
        } else {
            // iPhone: Use sheet
            content
                .sheet(isPresented: isPresented) {
                    self.content
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
        }
    }
}

extension View {
    func adaptiveModal<Content: View>(
        isPresented: Bool,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(AdaptiveModal(isPresented: isPresented, onDismiss: onDismiss, content: content()))
    }
}

// MARK: - Adaptive Grid System

struct AdaptiveCardGrid<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ViewBuilder let content: Content
    
    private var columns: [GridItem] {
        switch horizontalSizeClass {
        case .regular:
            // iPad: 4-6 columns depending on orientation
            return Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
        case .compact:
            // iPhone: 1-2 columns
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
        @unknown default:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            content
        }
    }
}

// MARK: - Hover Effects for iPad

struct HoverEffect: ViewModifier {
    @State private var isHovering = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

extension View {
    func hoverEffect() -> some View {
        modifier(HoverEffect())
    }
}

// MARK: - User Loading

private func loadUser() -> User {
    // Simple fallback user loading
    return User(name: "User")
}