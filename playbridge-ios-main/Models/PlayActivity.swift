//
//  PlayActivity.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct PlayActivity: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var summary: String
    var setupTimeMinutes: Int
    var activityTimeMinutes: Int
    var materials: [String]
    var setupSteps: [String]
    var childInstructions: [String]
    var imaginationPrompts: [String]
    var screenRequired: Bool
}
