import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("LifeDeck")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AI-Powered Life Coach")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Simple deck view
                VStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                            .frame(height: 200)
                            .overlay(
                                Text("Card \(index + 1)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("LifeDeck")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}