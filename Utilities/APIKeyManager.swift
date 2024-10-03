//  APIKeyManager.swift
import Foundation

class APIKeyManager {
    static func getAPIKey() -> String {
        #if DEBUG
        return Config.openAIApiKey
        #else
        // TODO: Implement Keychain Services retrieval here
        // This is a placeholder and should be replaced with secure storage before release
        return ""
        #endif
    }
}
