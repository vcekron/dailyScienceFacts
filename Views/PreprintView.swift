import SwiftUI

struct PreprintView: View {
    let preprint: Preprint

    @State private var colors: [Color] = []
    @State private var factTextColor: Color = .black
    @State private var displayedFact: String = ""
    @State private var isLoading: Bool = true
    @State private var shouldChangeColorAfterLoading: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    // Background gradient that changes color when tapped
                    LinearGradient(gradient: Gradient(colors: colors),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea(edges: .top)
                        .onTapGesture { changeColors(withDuration: 0.5) }

                    // Fact text displayed only after data is loaded
                    if !isLoading {
                        Text(displayedFact)
                            .font(.custom("Palatino", size: 22))
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 40)
                            .multilineTextAlignment(.center)
                            .foregroundColor(factTextColor)
                            .onTapGesture { changeColors(withDuration: 0.5) }
                            .transition(.opacity) // Fades in once the fact is available
                    } else {
                        // Placeholder space while loading fact
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 80)
                    }
                }

                // Display the preprint title
                Text(preprint.title)
                    .font(.title2)
                    .padding(.horizontal)

                // Display the authors of the preprint
                Text(preprint.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .padding(.horizontal)

                // Display the preprint abstract
                Text(preprint.abstract)
                    .padding([.horizontal, .bottom])
            }
        }
        .onAppear { initializeView() } // Trigger view initialization when it appears
        .onChange(of: preprint) { oldValue, newValue in
            updateView()  // Update view when the preprint changes
        }
        .onChange(of: isLoading) { oldValue, newValue in
            // Change colors after loading completes if needed
            if !newValue && shouldChangeColorAfterLoading {
                changeColors(withDuration: 0.5)
                shouldChangeColorAfterLoading = false
            }
        }
    }

    private func initializeView() {
        // Initialize colors and load the fact on view appearance
        changeColors(withDuration: 0.5)
        loadFact()
    }
    
    private func updateView() {
        // Ensure that colors change after loading the fact
        shouldChangeColorAfterLoading = true
        loadFact()
    }

    private func changeColors(withDuration duration: Double) {
        // Animate color change for the background gradient
        withAnimation(.easeInOut(duration: duration)) {
            colors = [randomColor(), randomColor()] // Set two random colors
            updateFactTextColor() // Adjust fact text color based on luminance
        }
    }

    private func loadFact() {
        // Load the fact based on the preprint's fact state
        switch preprint.fact {
        case .waitingForResponse:
            isLoading = true
            displayedFact = ""
            fetchFactIfNeeded() // Fetch the fact from API if necessary
        case .loaded(let fact):
            isLoading = false
            displayedFact = fact // Display the loaded fact
        }
    }

    private func fetchFactIfNeeded() {
        // Fetch the fact asynchronously if it hasn't been loaded yet
        if case .waitingForResponse = preprint.fact {
            Task {
                if let updatedFact = await fetchOpenAISummary(for: preprint) {
                    withAnimation {
                        displayedFact = updatedFact
                        isLoading = false
                    }
                }
            }
        }
    }

    private func fetchOpenAISummary(for preprint: Preprint) async -> String? {
        let service = ArxivServiceStatic()
        do {
            return try await service.fetchSummary(for: preprint) // Fetch summary from API
        } catch {
            print("Error fetching summary: \(error)") // Log error if fetching fails
            return nil
        }
    }

    private func randomColor() -> Color {
        // Generate a random color using RGB values
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }

    private func calculateLuminance(for color: Color) -> Double {
        // Calculate luminance based on the color's RGB values
        let components = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        return 0.299 * red + 0.587 * green + 0.114 * blue // Standard luminance formula
    }

    private func updateFactTextColor() {
        // Update the text color based on the background luminance for readability
        let averageLuminance = (calculateLuminance(for: colors[0]) + calculateLuminance(for: colors[1])) / 2
        factTextColor = averageLuminance > 0.5 ? .black : .white
    }
}
