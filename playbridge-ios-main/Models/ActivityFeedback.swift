//
//  ActivityFeedback.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Ebeveynin oynanmış bir aktivite için verdiği tek dokunuşluk geri bildirim.
///
/// Bu enum bilinçli olarak "beğendim / beğenmedim" ikilisinden daha zengin:
/// bir aktivitenin NEDEN tutmadığı, tutmadığı bilgisinden çok daha değerli.
/// "Çabuk sıkıldı" ile "çok zordu" birbirinden tamamen farklı iki düzeltme
/// gerektirir — ileride öğrenen çocuk profili ve başarı tahmin modeli bu
/// ayrımdan beslenecek.
enum ActivityFeedback: String, Codable, CaseIterable, Hashable, Identifiable {
    case worked
    case boredQuickly
    case tooHard
    case tooEasy
    case materialsDidntFit

    var id: String { rawValue }

    /// Ebeveyne gösterilen etiket. (Uygulamanın arayüz dili İngilizce.)
    var title: String {
        switch self {
        case .worked:            return "It worked"
        case .boredQuickly:      return "Got bored fast"
        case .tooHard:           return "Too hard"
        case .tooEasy:           return "Too easy"
        case .materialsDidntFit: return "Materials didn't fit"
        }
    }

    var systemImage: String {
        switch self {
        case .worked:            return "hand.thumbsup.fill"
        case .boredQuickly:      return "hourglass.bottomhalf.filled"
        case .tooHard:           return "exclamationmark.triangle.fill"
        case .tooEasy:           return "arrow.down.circle.fill"
        case .materialsDidntFit: return "shippingbox.fill"
        }
    }

    var isPositive: Bool { self == .worked }

    /// İleride üretim prompt'una eklenecek olan, modele hitap eden not.
    ///
    /// Bugün hiçbir yerde KULLANILMIYOR — ama geri bildirimi bugünden
    /// "modelin anlayacağı" bir cümleye çevirmek, öğrenen profil özelliğini
    /// eklerken tek yapılacak işi "bu notları toplayıp prompt'a koymak"
    /// haline getiriyor. Veri toplarken hedefi baştan doğru şekillendiriyoruz.
    var learningNote: String {
        switch self {
        case .worked:
            return "This kind of activity held the child's attention — do more like it."
        case .boredQuickly:
            return "The child lost interest quickly — make it shorter, more surprising, or more physical."
        case .tooHard:
            return "The activity was too difficult — simplify the steps and reduce the number of instructions."
        case .tooEasy:
            return "The activity was too easy — add a small challenge or an extra creative twist."
        case .materialsDidntFit:
            return "The suggested materials did not work in this home — stick to the simplest possible items."
        }
    }
}
