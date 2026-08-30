//
//  MealService.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum MealService {
    static func fetchPrompt(ageRange: String) async -> String {
        do {
            return try await fetchFromBackend(ageRange: ageRange)
        } catch {
            print("Meal prompt backend'e ulaşılamadı, yerel listeye düşülüyor: \(error)")
            return fallbackPrompts.randomElement() ?? fallbackPrompts[0]
        }
    }

    private static func fetchFromBackend(ageRange: String) async throws -> String {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/meal/prompt")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(MealPromptRequest(ageRange: ageRange))
        urlRequest.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(MealPromptResponse.self, from: data)
        return decoded.prompt
    }

    private static let fallbackPrompts = [
        "Can you find three red things on the table?",
        "If your fork could talk, what would it say?",
        "Let's make up a three-word story together — you start!"
    ]
}
