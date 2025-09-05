import SwiftUI

struct CoachingCardView: View {
    let card: CoachingCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: card.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                
                Spacer()
                
                Text(card.domain.displayName.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text(card.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(card.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Button(card.actionText) {
                // Handle card action
            }
            .buttonStyle(.lifeDeckCardAction(color: .white.opacity(0.2)))
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient.forDomain(card.domain)
        )
        .cornerRadius(20)
        .lifeDeckCardShadow()
    }
}
