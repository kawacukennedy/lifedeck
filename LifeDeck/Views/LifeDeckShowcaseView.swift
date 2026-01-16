import SwiftUI

// MARK: - LifeDeck Showcase View (Fixed for iPad Testing)

struct LifeDeckShowcaseView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            showcaseTab
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Showcase")
                }
                .tag(0)
        }
        .accentColor(.blue)
    }
    
    private var showcaseTab: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Text("LifeDeck Showcase")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("iPad-Optimized Features")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Feature cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    featureCard(
                        title: "Adaptive Layouts",
                        description: "Responsive design for all iPad sizes",
                        icon: "rectangle.3.group",
                        color: .blue
                    )
                    
                    featureCard(
                        title: "Sidebar Navigation",
                        description: "Native iPad navigation experience",
                        icon: "sidebar.left",
                        color: .green
                    )
                    
                    featureCard(
                        title: "Multi-Column Grids",
                        description: "4-6 columns for maximum content",
                        icon: "rectangle.grid.3x2",
                        color: .orange
                    )
                    
                    featureCard(
                        title: "Keyboard Shortcuts",
                        description: "Power user productivity features",
                        icon: "keyboard",
                        color: .purple
                    )
                }
                .padding()
                
                // Success indicator
                VStack(spacing: 15) {
                    Text("✅ iPad Testing Ready!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("All optimizations implemented")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Showcase")
    }
    
    private func featureCard(title: String, description: String, icon: String, color: Color) -> some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NavigationView {
        LifeDeckShowcaseView()
    }
}