import SwiftUI

/// Ultra-minimal showcase preview - loads instantly without DesignSystem dependencies
struct ShowcasePreview: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🃏 LifeDeck")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Design System Showcase")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Minimal • Calming • Premium • Futuristic")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Domain Cards
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Life Domains")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            domainCard("🏃", "Health", "Walk, exercise, meditate", .blue)
                            domainCard("💰", "Finance", "Save, invest, budget", .green)
                            domainCard("⏳", "Productivity", "Focus, organize, achieve", .orange)
                            domainCard("🧘", "Mindfulness", "Reflect, breathe, grow", .purple)
                        }
                    }
                    
                    // Sample Coaching Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sample Coaching Card")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: 12) {
                                    Text("🏃")
                                        .font(.system(size: 48))
                                    
                                    Text("Take a 5-minute walk")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text("A quick walk can boost your energy and mood")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Status
                    Text("✅ Preview System Working")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding()
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Showcase")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
    
    private func domainCard(_ icon: String, _ title: String, _ subtitle: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ShowcasePreview()
}
