import SwiftUI

/// Absolute minimal preview for testing - no dependencies at all
struct MinimalPreview: View {
    var body: some View {
        Text("✅ Preview Works")
            .font(.title)
            .foregroundColor(.blue)
            .padding()
    }
}

// Simple preview provider
#Preview {
    MinimalPreview()
}
