//
//  MealService.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum MealService {

    /// Backend'den konuya ve yaşa uygun bir soru ister.
    ///
    /// Herhangi bir aksilikte (sunucu kapalı, anahtar yok, kota doldu)
    /// sessizce yerel havuza düşüyor. Eskiden yedek yalnızca 3 sabit
    /// cümleydi ve yaşı hiç dikkate almıyordu; artık 80 soruluk,
    /// kademeye ve konuya saygılı bir havuz var — yani çevrimdışı
    /// deneyim de doğru soruyu veriyor.
    static func fetchPrompt(
        ageRange: String,
        category: MealPromptCategory,
        avoiding avoided: Set<String> = []
    ) async -> String {
        do {
            return try await fetchFromBackend(ageRange: ageRange, category: category)
        } catch {
            print("Meal prompt backend'e ulaşamadı, yerel havuza düşülüyor: \(error)")
            return MealPromptLibrary.random(
                for: AgeTier.from(ageRange: ageRange),
                category: category,
                avoiding: avoided
            )
        }
    }

    private static func fetchFromBackend(
        ageRange: String,
        category: MealPromptCategory
    ) async throws -> String {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/meal/prompt")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(
            MealPromptRequest(ageRange: ageRange, category: category.apiValue)
        )
        urlRequest.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode(MealPromptResponse.self, from: data).prompt
    }
}
