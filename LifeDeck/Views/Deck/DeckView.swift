import SwiftUI

struct DeckView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DeckViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Daily Coaching Cards")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Coming Soon: Swipeable coaching cards")
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Complete Sample Card") {
                    user.completeCard()
                }
                .buttonStyle(.lifeDeckPrimary())
                .padding()
                
                Spacer()
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
        }
    }
}
