import SwiftUI

struct ShowcasePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.xl) {
                Text("LifeDeck Component Showcase")
                    .font(DesignSystem.h1)
                    .foregroundColor(.white)

                // Button styles
                VStack {
                    Text("Button Styles")
                        .font(.title2)
                        .foregroundColor(.white)

                    Button("Primary") {}
                        .buttonStyle(.primary)

                    Button("Secondary") {}
                        .buttonStyle(.secondary)

                    Button("Premium") {}
                        .buttonStyle(.premium)

                    Button("Floating") {}
                        .buttonStyle(.floating)
                }

                // Card
                CoachingCardView(card: CoachingCard(text: "Sample coaching card", domain: .productivity)) { _ in }

                // Domain colors
                VStack {
                    Text("Domain Colors")
                        .font(.title2)
                        .foregroundColor(.white)

                    HStack {
                        ForEach(LifeDomainType.allCases, id: \.self) { domain in
                            Circle()
                                .fill(domainColor(domain))
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.background.edgesIgnoringSafeArea(.all))
    }

    private func domainColor(_ domain: LifeDomainType) -> Color {
        switch domain {
        case .health: return .health
        case .finance: return .finance
        case .productivity: return .productivity
        case .mindfulness: return .mindfulness
        }
    }
}

struct ShowcasePreview_Previews: PreviewProvider {
    static var previews: some View {
        ShowcasePreview()
    }
}