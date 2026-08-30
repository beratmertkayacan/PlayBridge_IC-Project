//
//  MealPrompt.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct MealPromptRequest: Codable {
    var ageRange: String
    /// Modelin odaklanacağı konu: masa, mutfak, yemek ya da hikâye.
    /// Opsiyonel — gönderilmezse backend eskisi gibi serbest üretir.
    var category: String?
}

struct MealPromptResponse: Codable {
    var prompt: String
}

/// Masada gerçekten sorulmuş bir soru.
///
/// Cevap SAKLANMIYOR — bu bilinçli. Çocuğun masada söylediklerini
/// kaydeden bir uygulama, sohbeti bir kayıt cihazına çevirir. Biz
/// yalnızca "soruldu" bilgisini tutuyoruz.
struct MealPromptRecord: Codable, Identifiable, Hashable {
    var id: String
    var prompt: String
    var category: MealPromptCategory
    var tier: AgeTier
    var createdAt: Date

    init(prompt: String, category: MealPromptCategory, tier: AgeTier, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.prompt = prompt
        self.category = category
        self.tier = tier
        self.createdAt = createdAt
    }
}
