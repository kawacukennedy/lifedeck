import SwiftUI

// MARK: - Minimal Preview
struct MinimalPreview: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            Text("LifeDeck Minimal Preview")
                .font(.largeTitle)
                .foregroundColor(.primary)
        }
    }
}

struct MinimalPreview_Previews: PreviewProvider {
    static var previews: some View {
        MinimalPreview()
    }
}