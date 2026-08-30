//
//  ScreenToPlayService.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum ScreenToPlayService {
    static func generateActivity(ageRange: String, screenTopic: String) async -> GeneratedActivityResponse {
        do {
            return try await fetchFromBackend(ageRange: ageRange, screenTopic: screenTopic)
        } catch {
            print("Screen-to-play backend'e ulaşılamadı, yerel mock'a düşülüyor: \(error)")
            return mockActivity(topic: screenTopic)
        }
    }

    private static func fetchFromBackend(ageRange: String, screenTopic: String) async throws -> GeneratedActivityResponse {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/screen-to-play/generate")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(
            ScreenToPlayRequest(ageRange: ageRange, screenTopic: screenTopic)
        )
        urlRequest.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode(GeneratedActivityResponse.self, from: data)
    }

    private static func mockActivity(topic: String) -> GeneratedActivityResponse {
        let firstWord = topic.split(separator: " ").first.map(String.init) ?? "World"
        let activity = PlayActivity(
            id: UUID().uuidString,
            title: "Invent Your Own \(firstWord.capitalized)",
            summary: "Turns the '\(topic)' topic into a hands-on drawing and imagination game.",
            setupTimeMinutes: 2,
            activityTimeMinutes: 15,
            materials: ["Paper", "Crayons"],
            setupSteps: ["Hand them paper and crayons."],
            childInstructions: ["Draw your own version of what you just watched.", "Give it a name."],
            imaginationPrompts: ["What does it do?", "Where does it live?", "What makes it special?"],
            screenRequired: false
        )
        let safety = SafetyReview(reviewed: true, safe: true, notes: [])
        return GeneratedActivityResponse(activity: activity, safety: safety)
    }
}
