import SwiftUI
import UIKit // Required for UIFont and UINavigationBarAppearance customization

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    init() {
        // Customize the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground() // Use default background for the navigation bar
        appearance.titleTextAttributes = [
            // Set custom font and color for the title text
            .font: UIFont(name: "Palatino-Bold", size: 24)!,
            .foregroundColor: UIColor.label
        ]
        // Apply appearance to both standard and scroll-edge navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the preprint if available, otherwise show a loading indicator
                if let preprint = viewModel.preprint {
                    PreprintView(preprint: preprint)
                } else {
                    Spacer(minLength: 10) // Add space above the progress view
                    ProgressView("Loading...")
                }

                Spacer() // Add flexible space at the bottom of the VStack

                BottomNavigationBar() // Custom bottom navigation component
            }
            .navigationTitle("Daily Science Facts") // Set the navigation bar title
            .navigationBarTitleDisplayMode(.inline) // Display title inline
            .task {
                // Asynchronously load a new fact when the view appears
                await viewModel.loadNewFact()
            }
            .refreshable {
                // Allow pull-to-refresh to load a new fact
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
