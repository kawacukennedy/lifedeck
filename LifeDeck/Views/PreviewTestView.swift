import SwiftUI

// MARK: - Preview Test
struct PreviewTestView: View {
    var body: some View {
        VStack {
            Text("Preview Test")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("Test Component")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .background(Color(.systemBackground))
    }
}

struct PreviewTestView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewTestView()
    }
}