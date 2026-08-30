//
//  MealPromptCategory.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Yemek sohbetinin konusu.
///
/// Kategoriyi ebeveyn SEÇMİYOR — uygulama sırayla dolaştırıyor. Meal
/// Mode'un tüm değeri "düşünmeden tek dokunuş" olmasında; masaya
/// oturmuş bir ebeveyne önce kategori seçtirmek bu değeri yok ederdi.
///
/// Kategoriyi uygulamanın seçmesinin ikinci faydası: hangi konudan kaç
/// soru sorulduğunu bildiğimiz için rozetleri cevaba bakmadan
/// verebiliyoruz — Draw & Collect'teki mantığın aynısı.
enum MealPromptCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case table
    case kitchen
    case food
    case story

    var id: String { rawValue }

    /// Soru ekranında üstte görünen küçük etiket.
    var label: String {
        switch self {
        case .table:   return "ON THE TABLE"
        case .kitchen: return "IN THE KITCHEN"
        case .food:    return "ON YOUR PLATE"
        case .story:   return "AT THE TABLE"
        }
    }

    var systemImage: String {
        switch self {
        case .table:   return "square.grid.2x2"
        case .kitchen: return "refrigerator"
        case .food:    return "carrot"
        case .story:   return "text.bubble"
        }
    }

    /// Backend'e gönderilen anahtar — model bu konuya odaklansın diye.
    var apiValue: String { rawValue }
}
