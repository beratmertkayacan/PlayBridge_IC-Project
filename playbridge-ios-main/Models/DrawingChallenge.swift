//
//  DrawingChallenge.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Çizim görevinin kategorisi.
///
/// Bu enum oyunun bel kemiği: rozet sistemi çizime BAKMADAN çalışabiliyor,
/// çünkü görevi zaten uygulama seçiyor — dolayısıyla "bu bir yaratık
/// çizimiydi" bilgisi fotoğrafı analiz etmeden elimizde oluyor.
enum SketchCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case creature
    case machine
    case place
    case invention
    case story
    case portrait

    var id: String { rawValue }

    var title: String {
        switch self {
        case .creature:  return "Creature"
        case .machine:   return "Machine"
        case .place:     return "Place"
        case .invention: return "Invention"
        case .story:     return "Story"
        case .portrait:  return "Portrait"
        }
    }

    var systemImage: String {
        switch self {
        case .creature:  return "pawprint"
        case .machine:   return "gearshape"
        case .place:     return "map"
        case .invention: return "lightbulb"
        case .story:     return "book"
        case .portrait:  return "person"
        }
    }
}

/// Görev zorluk kademesi. Çocuk profilindeki yaş aralığından türetiliyor.
///
/// Kademeler yukarı çıktıkça görevin doğası değişiyor: küçük yaşta tek
/// bir nesne isteniyor, büyük yaşta bir KISIT veriliyor ("sadece üçgen
/// kullanarak"). 11-12 yaşındaki bir çocuğa "bir ev çiz" demek onu
/// kaybetmenin en hızlı yolu.
enum AgeTier: String, Codable, CaseIterable, Hashable {
    case tier3to4   = "3-4"
    case tier5to6   = "5-6"
    case tier7to8   = "7-8"
    case tier9to10  = "9-10"
    case tier11to12 = "11-12"

    /// Profildeki yaş aralığı metninden kademe bulur.
    ///
    /// Eşleşme bulunamazsa (örn. eski profillerdeki "7" değeri) en yakın
    /// makul kademeye düşüyoruz — kullanıcı hiçbir zaman boş ekran görmemeli.
    static func from(ageRange: String) -> AgeTier {
        if let exact = AgeTier(rawValue: ageRange) { return exact }
        // Eski sürümde yaş aralıkları "3-4" / "5-6" / "7" idi.
        let firstNumber = Int(ageRange.prefix(while: \.isNumber)) ?? 5
        switch firstNumber {
        case ..<5:   return .tier3to4
        case 5...6:  return .tier5to6
        case 7...8:  return .tier7to8
        case 9...10: return .tier9to10
        default:     return .tier11to12
        }
    }

    var label: String { rawValue }
}

/// Tek bir çizim görevi.
struct DrawingChallenge: Codable, Hashable, Identifiable {
    var id: String { "\(tier.rawValue)|\(category.rawValue)|\(text)" }
    var text: String
    var category: SketchCategory
    var tier: AgeTier
}
