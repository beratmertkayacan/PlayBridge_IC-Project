//
//  MealPrompt.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct MealPromptRequest: Codable {
    var ageRange: String
}

struct MealPromptResponse: Codable {
    var prompt: String
}
