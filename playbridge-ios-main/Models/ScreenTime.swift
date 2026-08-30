//
//  ScreenTime.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

struct ScreenTimeLogRequest: Codable {
    var savedMinutes: Int
}

struct ScreenTimeLogResponse: Codable {
    var id: Int
    var savedMinutes: Int
}

struct ScreenTimeWeekResponse: Codable {
    var savedMinutesThisWeek: Int
}
