// ArxivService.swift
import Foundation
import SWXMLHash

class ArxivService {
    func fetchLatestPreprint() async throws -> Preprint? {
        let urlString = "http://export.arxiv.org/api/query?search_query=all&start=0&max_results=1&sortBy=submittedDate&sortOrder=descending"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        let preprints = try parseArxivData(data)
        return preprints.first
    }

    private func parseArxivData(_ data: Data) throws -> [Preprint] {
        let xml = SWXMLHash.XMLHash.parse(data)
        var preprints: [Preprint] = []

        for entry in xml["feed"]["entry"].all {
            let id = entry["id"].element?.text ?? ""
            
            var title = entry["title"].element?.text ?? "No Title"
            title = title.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)

            var summary = entry["summary"].element?.text ?? "No Summary"
            summary = summary.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)

            let authors = entry["author"].all.compactMap { $0["name"].element?.text }
            let link = entry["id"].element?.text ?? ""
            let publishedString = entry["published"].element?.text ?? ""
            let publishedDate = ISO8601DateFormatter().date(from: publishedString) ?? Date()

            let preprint = Preprint(
                id: id,
                title: title,
                abstract: summary,
                authors: authors,
                link: link,
                publishedDate: publishedDate,
                fact: "An improved one-to-all communication algorithm for higher-dimensional Eisenstein-Jacobi networks reduces the average number of steps for message broadcasting and demonstrates better traffic performance compared to traditional algorithms, achieving 2.7% less total number of senders."
            )

            preprints.append(preprint)
        }

        return preprints
    }
}
