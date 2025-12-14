import SwiftUI

struct SimplePreview: View {
    var body: some View {
        Text("Hello, LifeDeck!")
            .font(DesignSystem.h1)
            .foregroundColor(.primary)
            .background(Color.background)
    }
}

struct SimplePreview_Previews: PreviewProvider {
    static var previews: some View {
        SimplePreview()
    }
}