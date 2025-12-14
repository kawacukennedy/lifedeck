import SwiftUI

struct PreviewTestView: View {
    var body: some View {
        VStack {
            Text("Preview Test")
                .font(DesignSystem.h1)
                .foregroundColor(.white)

            CoachingCardView(card: CoachingCard(text: "Test card", domain: .health)) { _ in }
        }
        .background(Color.background)
    }
}

struct PreviewTestView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewTestView()
    }
}