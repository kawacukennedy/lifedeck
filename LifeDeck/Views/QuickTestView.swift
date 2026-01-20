import SwiftUI

// MARK: - Quick Test View
struct QuickTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Quick Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("LifeDeck Component Test")
                .font(.headline)
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 100)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct QuickTestView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTestView()
    }
}