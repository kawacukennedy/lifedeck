import SwiftUI

/// Ultra-minimal ContentView for fast app launch and testing
struct FastContentView: View {
    var body: some View {
        TabView {
            // Simple Text Views for each tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🃏 LifeDeck")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Welcome to your AI-powered micro-coach")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                        
                        // Sample cards
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.gradient)
                                .frame(height: 150)
                                .overlay(
                                    VStack {
                                        Text("Sample Card \(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("This is a coaching card")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                )
                        }
                    }
                    .padding()
                }
                .navigationTitle("Deck")
            }
            .tabItem {
                Image(systemName: "rectangle.stack")
                Text("Deck")
            }
            .tag(0)
            
            NavigationView {
                VStack(spacing: 30) {
                    Text("📊 Progress")
                        .font(.largeTitle)
                    
                    Text("Your journey at a glance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Sample progress view
                    VStack(spacing: 15) {
                        HStack {
                            Text("Health")
                            Spacer()
                            ProgressView(value: 0.7)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Finance")
                            Spacer()
                            ProgressView(value: 0.4)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Productivity")
                            Spacer()
                            ProgressView(value: 0.6)
                                .frame(width: 100)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding()
                .navigationTitle("Progress")
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Progress")
            }
            .tag(1)
            
            NavigationView {
                VStack(spacing: 30) {
                    Text("👤 Profile")
                        .font(.largeTitle)
                    
                    Text("Your LifeDeck settings")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 20) {
                        Label("Alex Johnson", systemImage: "person.circle")
                        Label("Premium Member", systemImage: "crown")
                        Label("Settings", systemImage: "gear")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding()
                .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.circle")
                Text("Profile")
            }
            .tag(2)
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FastContentView()
}
