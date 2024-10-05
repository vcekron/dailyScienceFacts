import SwiftUI

struct BottomNavigationBar: View {
    var body: some View {
        HStack {
            Spacer()
            
            // Home button
            NavigationButton(imageName: "house.fill", label: "Home", action: {})
            Spacer()
            
            // Browse button
            NavigationButton(imageName: "magnifyingglass", label: "Browse", action: {})
            Spacer()
            
            // Saved button
            NavigationButton(imageName: "bookmark.fill", label: "Saved", action: {})
            Spacer()
        }
        .padding(.top, 2) // Add some padding at the top for spacing
        .background(Color(.systemBackground)) // Background color from system theme
        .foregroundColor(Color(.label)) // Adjust text and icon colors to system label color
        .overlay(
            VStack(spacing: 50) {
                // Add a thin separator line above the navigation bar
                Color(.separator)
                    .frame(height: 0.5)
                Spacer()
            }
        )
    }
}

struct NavigationButton: View {
    let imageName: String // SF Symbol name for button icon
    let label: String // Button label text
    let action: () -> Void // Action to perform on tap

    var body: some View {
        Button(action: action) {
            VStack {
                // Icon for the button
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23) // Icon size
                    .padding(.bottom, -2) // Small padding to adjust spacing
                // Label for the button
                Text(label)
                    .font(.footnote) // Use smaller font for navigation labels
            }
        }
    }
}
