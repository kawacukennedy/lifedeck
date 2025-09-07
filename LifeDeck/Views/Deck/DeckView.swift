import SwiftUI

struct DeckView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DeckViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🃏 LifeDeck")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("AI-Powered Micro-Coach")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Your daily coaching cards await!")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Complete Sample Card") {
                user.completeCard()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            HStack {
                VStack {
                    Text("\(user.progress.currentStreak)")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("Streak")
                        .foregroundColor(.gray)
                }
                .padding()
                
                VStack {
                    Text("\(user.progress.lifePoints)")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("Points")
                        .foregroundColor(.gray)
                }
                .padding()
                
                VStack {
                    Text("\(user.progress.totalCardsCompleted)")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("Cards")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Deck")
        .navigationBarTitleDisplayMode(.large)
    }
}
