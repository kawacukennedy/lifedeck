import SwiftUI

struct MinimalPreview: View {
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            Text("LifeDeck Minimal Preview")
                .font(DesignSystem.h1)
                .foregroundColor(.white)
        }
    }
}

struct MinimalPreview_Previews: PreviewProvider {
    static var previews: some View {
        MinimalPreview()
    }
}