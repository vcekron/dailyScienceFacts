// BottomNavigationBar.swift
import SwiftUI

struct BottomNavigationBar: View {
    var body: some View {
        HStack {
            Spacer()
            NavigationButton(imageName: "house.fill", label: "Home") {
                // Home action
            }
            Spacer()
            NavigationButton(imageName: "magnifyingglass", label: "Browse") {
                // Browse action
            }
            Spacer()
            NavigationButton(imageName: "bookmark.fill", label: "Saved") {
                // Saved action
            }
            Spacer()
        }
        .padding(.top, 2)
        .background(Color(.systemBackground))
        .foregroundColor(Color(.label))
        .overlay(
            VStack(spacing: 50) {
                Color(.separator)
                    .frame(height: 0.5) // Adjust the height to match the navigation bar's divider
                Spacer()
            }
        )
    }
}

struct NavigationButton: View {
    let imageName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
                    .padding(.bottom, -2)
                Text(label)
                    .font(.footnote)
            }
        }
    }
}
