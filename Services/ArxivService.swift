// ArxivService.swift
import Foundation
import SWXMLHash
import OpenAI

class ArxivService {
    func fetchLatestPreprint() async throws -> Preprint? {
        let urlString = "http://export.arxiv.org/api/query?search_query=all&start=0&max_results=1&sortBy=submittedDate&sortOrder=descending"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        let preprints = try await parseArxivData(data)
        return preprints.first
    }
    
    func generateFact(from summary: String) async throws -> String {
        let apiKey = APIKeyManager.getAPIKey()
        let openAI = OpenAI(apiToken: apiKey)
        let prompt = """
        Generate one factual sentance to summarize the following text. Make it as short and consise as possible! ONLY RETURN THE GENERATED SENTANCE!

        \(summary)
        """

        guard let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
            throw NSError(domain: "ArxivServiceStatic", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user message."])
        }

        let chatQuery = ChatQuery(
            messages: [userMessage],
            model: .gpt4_o_mini,
            maxTokens: 250,
            temperature: 0.5
        )

        let result = try await openAI.chats(query: chatQuery)
        return result.choices.first?.message.content?.string ?? "No fact generated"
    }

    private func parseArxivData(_ data: Data) async throws -> [Preprint] {
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
            
            let fact = try await generateFact(from: summary)
            
            let preprint = Preprint(
                id: id,
                title: title,
                abstract: summary,
                authors: authors,
                link: link,
                publishedDate: publishedDate,
                fact: fact
            )
            
            preprints.append(preprint)
        }
        
        return preprints
    }
}
