// ContentViewModel.swift
import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var preprint: Preprint?
    private let arxivService = ArxivServiceStatic()

    func loadNewFact() async {
        do {
            preprint = try await arxivService.fetchLatestPreprint()
        } catch {
            print("Error fetching preprint: \(error)")
        }
    }
}
