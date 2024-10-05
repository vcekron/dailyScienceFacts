import SwiftUI
import UIKit

struct PreprintView: View {
    let preprint: Preprint
    let generator = UIImpactFeedbackGenerator(style: .light)

    @State private var colors: [Color] = []
    @State private var factTextColor: Color = .black
    @State private var displayedFact: String = ""
    @State private var isLoading: Bool = true
    @State private var shouldChangeColorAfterLoading: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    // Background gradient changes color on tap
                    LinearGradient(gradient: Gradient(colors: colors),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea(edges: .top)
                        .onTapGesture {
                            generator.impactOccurred() // Trigger haptic feedback
                            changeColors(withDuration: 0.5) // Change colors with animation
                        }

                    // Display fact after it has loaded, otherwise show a placeholder
                    if !isLoading {
                        Text(displayedFact)
                            .font(.custom("Palatino", size: 22))
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 40)
                            .multilineTextAlignment(.center)
                            .foregroundColor(factTextColor) // Adjust text color for readability
                            .onTapGesture {
                                generator.impactOccurred() // Trigger haptic feedback
                                changeColors(withDuration: 0.5) // Change colors on tap
                            }
                            .transition(.opacity) // Fade in text once it's ready
                    } else {
                        // Placeholder height while the fact is loading
                        Rectangle().fill(Color.clear).frame(height: 80)
                    }
                }

                // Display preprint title
                Text(preprint.title)
                    .font(.title2)
                    .padding(.horizontal)

                // Display authors of the preprint
                Text(preprint.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .padding(.horizontal)

                // Display preprint abstract
                Text(preprint.abstract)
                    .padding([.horizontal, .bottom])
            }
        }
        .onAppear(perform: initializeView) // Initialize view on appearance
        .onChange(of: preprint) { oldValue, newValue in
            updateView()  // Update view when the preprint changes
        }
        .onChange(of: isLoading) { oldValue, newValue in
            // Change colors after loading completes if needed
            if !newValue && shouldChangeColorAfterLoading {
                changeColors(withDuration: 0.5)
                generator.impactOccurred() // Haptic feedback when a new fact is displayed
                shouldChangeColorAfterLoading = false
            }
        }
    }

    private func initializeView() {
        // Initial color change and fact loading
        changeColors(withDuration: 0.5)
        loadFact()
    }
    
    private func updateView() {
        // When the preprint updates, ensure that colors will change after fact loads
        shouldChangeColorAfterLoading = true
        loadFact()
    }

    private func changeColors(withDuration duration: Double) {
        // Animate a smooth background color transition
        withAnimation(.easeInOut(duration: duration)) {
            colors = [randomColor(), randomColor()] // Generate two random colors
            updateFactTextColor() // Adjust text color for best readability
        }
    }

    private func loadFact() {
        // Load the fact if available, otherwise fetch from the API
        switch preprint.fact {
        case .waitingForResponse:
            isLoading = true
            displayedFact = ""
            fetchFactIfNeeded() // Fetch fact if needed
        case .loaded(let fact):
            isLoading = false
            displayedFact = fact // Display the fact once it's loaded
        }
    }

    private func fetchFactIfNeeded() {
        // Fetch fact asynchronously from the API if it is not loaded
        if case .waitingForResponse = preprint.fact {
            Task {
                if let updatedFact = await fetchOpenAISummary(for: preprint) {
                    withAnimation {
                        displayedFact = updatedFact
                        isLoading = false
                        generator.impactOccurred() // Trigger haptic feedback after loading
                    }
                }
            }
        }
    }

    private func fetchOpenAISummary(for preprint: Preprint) async -> String? {
        let service = ArxivServiceStatic()
        do {
            return try await service.fetchSummary(for: preprint) // Fetch from API
        } catch {
            print("Error fetching summary: \(error)") // Log error if fetching fails
            return nil
        }
    }

    private func randomColor() -> Color {
        // Generate a random color using RGB values
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }

    private func calculateLuminance(for color: Color) -> Double {
        // Calculate the luminance to determine if the color is light or dark
        let components = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        return 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
    }

    private func updateFactTextColor() {
        // Adjust text color for contrast based on the average background luminance
        let averageLuminance = (calculateLuminance(for: colors[0]) + calculateLuminance(for: colors[1])) / 2
        factTextColor = averageLuminance > 0.5 ? .black : .white
    }
}
