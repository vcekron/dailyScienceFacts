import SwiftUI

struct PreprintView: View {
    let preprint: Preprint

    @State private var colors: [Color] = []
    @State private var factTextColor: Color = .black

    func randomColor() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }

    func calculateLuminance(for color: Color) -> Double {
        let components = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]

        // Standard formula for relative luminance
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }

    func updateFactTextColor() {
        // Get the luminance for both the lightest and darkest colors in the gradient
        let luminance1 = calculateLuminance(for: colors[0])
        let luminance2 = calculateLuminance(for: colors[1])
        
        // Average luminance
        let averageLuminance = (luminance1 + luminance2) / 2
        
        // If either part of the gradient is very light or very dark, adjust the text color accordingly
        factTextColor = averageLuminance > 0.5 ? .black : .white
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: colors),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .ignoresSafeArea(edges: .top)
                    
                    Text(preprint.fact)
                        .font(.custom("Palatino", size: 22))
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 40)
                        .multilineTextAlignment(.center)
                        .foregroundColor(factTextColor) // Set dynamic text color for preprint.fact
                }

                // Title
                Text(preprint.title)
                    .font(.title2)
                    .padding(.horizontal)

                // Authors
                Text(preprint.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .padding(.horizontal)

                // Abstract
                Text(preprint.abstract)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            colors = [randomColor(), randomColor()]
            updateFactTextColor() // Update text color for preprint.fact based on background color
        }
        .onChange(of: preprint) {
            colors = [randomColor(), randomColor()]
            updateFactTextColor() // Update text color for preprint.fact based on background color
        }
    }
}
