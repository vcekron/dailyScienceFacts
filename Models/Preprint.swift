import Foundation

// Enum representing the state of the fact
enum FactState: Equatable {
    case waitingForResponse
    case loaded(String)
}

// Updated Preprint struct to use FactState for the fact field
struct Preprint: Equatable {
    let id: String
    let title: String
    let abstract: String
    let authors: [String]
    let link: String
    let publishedDate: Date
    var fact: FactState = .waitingForResponse  // Default state is waiting
}
