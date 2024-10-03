// ContentView.swift
import SwiftUI
import UIKit // Import UIKit to use UIFont and UINavigationBarAppearance

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    init() {
        // Customize the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Palatino-Bold", size: 24)!,
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let preprint = viewModel.preprint {
                    PreprintView(preprint: preprint)
                } else {
                    Spacer(minLength: 10)
                    ProgressView("Loading...")
                }

                Spacer() // Added back the Spacer

                BottomNavigationBar()
            }
            .navigationTitle("Daily Science Facts")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadNewFact()
            }
            .refreshable {
                await viewModel.loadNewFact()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
