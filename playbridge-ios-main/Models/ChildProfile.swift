//
//  ChildProfile.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct ChildProfile: Codable, Equatable {
    var ageRange: String              // "3-4", "5-6", "7"
    var interests: [String]           // örn. ["dinosaurs", "space"]
    var availableMaterials: [String]  // örn. ["paper", "crayons"]
    var preferredActivityDuration: Int // dakika, örn. 15
}
