import SwiftUI

// MARK: - Showcase Preview
struct ShowcasePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("LifeDeck Showcase")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Component Library")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                // Button showcase
                VStack {
                    Text("Button Styles")
                        .font(.headline)
                    Button("Primary Button") {}
                        .primaryButtonStyle()
                    Button("Secondary Button") {}
                        .secondaryButtonStyle()
                }
                .padding()
                
                // Card showcase
                VStack {
                    Text("Card Components")
                        .font(.headline)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                        .frame(width: 200, height: 100)
                        .overlay(
                            Text("Card")
                                .foregroundColor(.white)
                        )
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ShowcasePreview_Previews: PreviewProvider {
    static var previews: some View {
        ShowcasePreview()
    }
}