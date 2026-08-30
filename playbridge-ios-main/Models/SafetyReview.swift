//
//  SafetyReview.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct SafetyReview: Codable, Hashable {
    var reviewed: Bool
    var safe: Bool
    var notes: [String]
}
