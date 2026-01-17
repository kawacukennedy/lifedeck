import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Deck")
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Deck")
                }
            
            Text("Progress")
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Progress")
                }
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}