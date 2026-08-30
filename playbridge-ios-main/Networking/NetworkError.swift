//
//  NetworkError.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server sent an unexpected response."
        case .serverError(let statusCode):
            return "The server returned an error (\(statusCode))."
        case .decodingFailed:
            return "Could not understand the server's response."
        }
    }
}
