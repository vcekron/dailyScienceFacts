// ContentViewModel.swift

import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var preprint: Preprint?
    private let arxivService = ArxivServiceStatic()

    // Asynchronously fetches the latest preprint from the arXiv service.
    func loadNewFact() async {
        do {
            preprint = try await arxivService.fetchLatestPreprint()
        } catch {
            // Log the error for debugging or reporting purposes.
            print("Error fetching preprint: \(error.localizedDescription)")
        }
    }
}
