//
//  ActivityService.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum ActivityService {

    /// Ana giriş noktası: önce gerçek backend'i dener, herhangi bir
    /// hata durumunda (sunucu kapalı, ağ sorunu, timeout, decode
    /// hatası) sessizce yerel mock'a düşer.
    static func generateActivity(for request: ActivityRequest) async -> GeneratedActivityResponse {
        do {
            return try await fetchFromBackend(request: request)
        } catch {
            print("Backend'e ulaşılamadı, yerel mock'a düşülüyor: \(error)")
            return await generateMockActivity(for: request)
        }
    }

    private static func fetchFromBackend(request: ActivityRequest) async throws -> GeneratedActivityResponse {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/activity/generate")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(GeneratedActivityResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    /// Phase 6'dan kalma yerel mock — artık sadece backend'e HİÇ
    /// ulaşılamadığında yedek olarak kullanılıyor.
    static func generateMockActivity(for request: ActivityRequest) async -> GeneratedActivityResponse {
        try? await Task.sleep(nanoseconds: 800_000_000)

        if request.mode == "together",
           request.location == "In the car",
           request.availableMaterials.isEmpty {
            return carWindowMock(duration: request.durationMinutes, setup: request.parentSetupMinutes)
        }

        let primaryInterest = request.interests.first ?? "imagination"
        let title = "\(primaryInterest.capitalized) Adventure"

        let activity = PlayActivity(
            id: UUID().uuidString,
            title: title,
            summary: "A simple \(primaryInterest.lowercased())-themed activity your child can enjoy independently.",
            setupTimeMinutes: request.parentSetupMinutes,
            activityTimeMinutes: request.durationMinutes,
            materials: request.availableMaterials,
            setupSteps: [
                "Gather the materials in one spot.",
                "Set the scene with a short, simple story hook."
            ],
            childInstructions: [
                "Explore the \(primaryInterest.lowercased()) world you've set up.",
                "Invent a short story about what happens next."
            ],
            imaginationPrompts: [
                "What do you see?",
                "What happens next?",
                "How does the story end?"
            ],
            screenRequired: false
        )

        let safety = SafetyReview(reviewed: true, safe: true, notes: [])
        return GeneratedActivityResponse(activity: activity, safety: safety)
    }

    private static func carWindowMock(duration: Int, setup: Int) -> GeneratedActivityResponse {
        let activity = PlayActivity(
            id: UUID().uuidString,
            title: "Red Car Hunt",
            summary: "A looking game you play from your seats. Nothing in your hands. Just the view out the window.",
            setupTimeMinutes: setup,
            activityTimeMinutes: duration,
            materials: [],
            setupSteps: [
                "Stay buckled. Look out the windows together."
            ],
            childInstructions: [
                "Count every red car you see.",
                "Then switch: find a blue car, then a truck."
            ],
            imaginationPrompts: [
                "Where do you think that red car is going?",
                "What would a giant truck say if it could talk?",
                "Can you spot something the same color as your shirt?"
            ],
            screenRequired: false
        )
        let safety = SafetyReview(reviewed: true, safe: true, notes: [])
        return GeneratedActivityResponse(activity: activity, safety: safety)
    }
}
