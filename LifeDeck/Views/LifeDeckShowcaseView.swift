import SwiftUI

// MARK: - LifeDeck Showcase View
struct LifeDeckShowcaseView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("LifeDeck Showcase")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    // Domain showcase
                    VStack {
                        Text("Life Domains")
                            .font(.title2)
                        
                        HStack {
                            VStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Health")
                            }
                            
                            VStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.green)
                                Text("Finance")
                            }
                            
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Productivity")
                            }
                            
                            VStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.purple)
                                Text("Mindfulness")
                            }
                        }
                    }
                    .padding()
                    
                    // Card showcase
                    VStack {
                        Text("Card System")
                            .font(.title2)
                        
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Text("Card \(index + 1)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("AI-powered coaching")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                )
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct LifeDeckShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        LifeDeckShowcaseView()
    }
}