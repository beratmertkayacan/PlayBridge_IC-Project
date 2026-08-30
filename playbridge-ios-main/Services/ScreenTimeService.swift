//
//  ScreenTimeService.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

enum ScreenTimeService {

    static func log(savedMinutes: Int) async throws -> ScreenTimeLogResponse {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/screen-time/log")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(ScreenTimeLogRequest(savedMinutes: savedMinutes))
        urlRequest.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("screen-time/log HTTP \(httpResponse.statusCode): \(body)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(ScreenTimeLogResponse.self, from: data)
    }

    static func fetchMinutesThisWeek() async -> Int {
        do {
            return try await fetchFromBackend()
        } catch {
            print("Bu haftanın ekran süresi toplamı alınamadı: \(error)")
            return 0
        }
    }

    private static func fetchFromBackend() async throws -> Int {
        let url = APIConfig.baseURL.appendingPathComponent("api/v1/screen-time/this-week")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("screen-time/this-week HTTP \(httpResponse.statusCode): \(body)")
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        let decoded = try JSONDecoder().decode(ScreenTimeWeekResponse.self, from: data)
        return decoded.savedMinutesThisWeek
    }
}
