import SwiftUI

/// Absolute minimal preview for testing
struct PreviewTestView: View {
    var body: some View {
        VStack {
            Text("🃏 LifeDeck")
                .font(.title)
            Text("Preview Test")
                .foregroundColor(.blue)
        }
        .padding()
    }

}

#Preview {
    PreviewTestView()
}
