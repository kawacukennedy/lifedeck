import SwiftUI

// MARK: - Simple Preview Component
struct SimplePreview: View {
    var body: some View {
        Text("Hello, LifeDeck!")
            .font(.largeTitle)
            .foregroundColor(.primary)
            .background(Color(.systemBackground))
            .padding()
    }
}

struct SimplePreview_Previews: PreviewProvider {
    static var previews: some View {
        SimplePreview()
    }
}