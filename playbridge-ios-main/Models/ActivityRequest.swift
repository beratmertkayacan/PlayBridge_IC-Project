//
//  ActivityRequest.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct ActivityRequest: Codable, Hashable {
    var ageRange: String
    var interests: [String]
    var availableMaterials: [String]
    var durationMinutes: Int
    var parentSetupMinutes: Int
    var mode: String   // "independent", "together", "meal", "screen_to_play"
}
