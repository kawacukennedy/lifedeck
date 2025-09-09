import SwiftUI

/// Ultra-minimal static preview with no custom dependencies
struct PreviewTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🃏 LifeDeck")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            Text("Static Preview Working")
                .font(.title2)
                .foregroundColor(.blue)
            
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 16, height: 16)
                Text("Status: Active")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Rectangle()
                .fill(.gray.opacity(0.2))
                .frame(height: 80)
                .cornerRadius(8)
                .overlay {
                    Text("Mock Content Area")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            
            HStack(spacing: 12) {
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(width: 60, height: 40)
                    .cornerRadius(6)
                
                Rectangle()
                    .fill(.green.opacity(0.3))
                    .frame(width: 60, height: 40)
                    .cornerRadius(6)
                
                Rectangle()
                    .fill(.orange.opacity(0.3))
                    .frame(width: 60, height: 40)
                    .cornerRadius(6)
            }
            
            Text("No app launch required")
                .font(.caption)
                .foregroundColor(Color.secondary)
            
            Spacer()
        }
        .padding(24)
        .background(.background)
    }

}

// MARK: - Static Preview Provider
struct PreviewTestView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewTestView()
    }
}
