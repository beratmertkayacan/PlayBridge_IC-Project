//
//  SketchBadge.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Kazanılabilir rozetler.
///
/// Hiçbiri çizimin İÇERİĞİNE bakmıyor — hepsi sayılabilir yerel
/// veriden hesaplanıyor: kaç çizim, hangi kategoriden, hangi hafta,
/// saat kaçta. Bu, "fotoğraf cihazdan çıkmaz" kuralını hiç zorlamadan
/// gerçek bir koleksiyon oyunu kurmayı mümkün kılıyor.
enum SketchBadge: String, Codable, CaseIterable, Identifiable, Hashable {
    case firstSketch
    case collectorI
    case collectorII
    case collectorIII
    case sixOfSix

    case creatureMaker
    case engineer
    case worldBuilder
    case inventor
    case storyteller
    case portraitArtist

    case fullWeek
    case threeWeeks
    case backAgain

    case earlyBird
    case roadArtist

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstSketch:    return "First Sketch"
        case .collectorI:     return "The Collector I"
        case .collectorII:    return "The Collector II"
        case .collectorIII:   return "The Collector III"
        case .sixOfSix:       return "Six of Six"
        case .creatureMaker:  return "Creature Maker"
        case .engineer:       return "Engineer"
        case .worldBuilder:   return "World Builder"
        case .inventor:       return "Inventor"
        case .storyteller:    return "Storyteller"
        case .portraitArtist: return "Portrait Artist"
        case .fullWeek:       return "Full Week"
        case .threeWeeks:     return "Three Weeks"
        case .backAgain:      return "Back Again"
        case .earlyBird:      return "Early Bird"
        case .roadArtist:     return "Road Artist"
        }
    }

    /// Rozet kazanıldığında çocuğa gösterilen tek cümle.
    var caption: String {
        switch self {
        case .firstSketch:    return "Your very first drawing is in the book."
        case .collectorI:     return "Five drawings collected."
        case .collectorII:    return "Fifteen drawings collected."
        case .collectorIII:   return "Thirty drawings collected."
        case .sixOfSix:       return "You have drawn from all six kinds."
        case .creatureMaker:  return "Three creatures brought to life."
        case .engineer:       return "Three machines built on paper."
        case .worldBuilder:   return "Three places that did not exist before."
        case .inventor:       return "Three inventions nobody thought of."
        case .storyteller:    return "Three moments from three stories."
        case .portraitArtist: return "Three faces, drawn your way."
        case .fullWeek:       return "You filled a whole week."
        case .threeWeeks:     return "Three weeks in a row."
        case .backAgain:      return "You came back. That counts too."
        case .earlyBird:      return "Drawn before the day got busy."
        case .roadArtist:     return "Drawn on the road."
        }
    }

    var systemImage: String {
        switch self {
        case .firstSketch:    return "sparkles"
        case .collectorI:     return "square.stack"
        case .collectorII:    return "square.stack.3d.up"
        case .collectorIII:   return "square.stack.3d.up.fill"
        case .sixOfSix:       return "circle.hexagongrid"
        case .creatureMaker:  return "pawprint.fill"
        case .engineer:       return "gearshape.fill"
        case .worldBuilder:   return "map.fill"
        case .inventor:       return "lightbulb.fill"
        case .storyteller:    return "book.fill"
        case .portraitArtist: return "person.fill"
        case .fullWeek:       return "checkmark.seal.fill"
        case .threeWeeks:     return "flame.fill"
        case .backAgain:      return "arrow.uturn.backward.circle.fill"
        case .earlyBird:      return "sunrise.fill"
        case .roadArtist:     return "car.fill"
        }
    }

    static func categoryBadge(for category: SketchCategory) -> SketchBadge {
        switch category {
        case .creature:  return .creatureMaker
        case .machine:   return .engineer
        case .place:     return .worldBuilder
        case .invention: return .inventor
        case .story:     return .storyteller
        case .portrait:  return .portraitArtist
        }
    }
}

/// Bir çizim kaydedildiği anda rozet değerlendirmesi için gereken her şey.
struct BadgeContext {
    var totalSketches: Int
    var countsByCategory: [SketchCategory: Int]
    var sketchesThisWeek: Int
    var weeklyGoal: Int
    var consecutiveFullWeeks: Int
    /// Bir önceki çizimden bu yana geçen gün. İlk çizimde nil.
    var daysSincePreviousSketch: Int?
    var createdAt: Date
    /// Son bir saat içinde "In the car" seçilerek oynanmış bir aktivite var mı?
    var playedInCarRecently: Bool

    /// Bu kayıtla birlikte YENİ kazanılan rozetler.
    ///
    /// `alreadyEarned` zaten kazanılmış olanları eler — aynı rozet iki kez
    /// verilmiyor, dolayısıyla rozet anı ekranı da tekrar etmiyor.
    func newlyEarned(alreadyEarned: Set<SketchBadge>) -> [SketchBadge] {
        var earned: [SketchBadge] = []

        if totalSketches >= 1  { earned.append(.firstSketch) }
        if totalSketches >= 5  { earned.append(.collectorI) }
        if totalSketches >= 15 { earned.append(.collectorII) }
        if totalSketches >= 30 { earned.append(.collectorIII) }

        if SketchCategory.allCases.allSatisfy({ (countsByCategory[$0] ?? 0) >= 1 }) {
            earned.append(.sixOfSix)
        }

        for category in SketchCategory.allCases where (countsByCategory[category] ?? 0) >= 3 {
            earned.append(SketchBadge.categoryBadge(for: category))
        }

        if sketchesThisWeek >= weeklyGoal { earned.append(.fullWeek) }
        if consecutiveFullWeeks >= 3      { earned.append(.threeWeeks) }

        // Dönüşü ÖDÜLLENDİREN rozet. Klasik seri mekaniği kaybı
        // cezalandırır; burada tersini yapıyoruz — bir haftadan uzun ara
        // verip dönen ebeveyn hoş karşılanıyor, azarlanmıyor.
        if let gap = daysSincePreviousSketch, gap >= 8 { earned.append(.backAgain) }

        let hour = Calendar.current.component(.hour, from: createdAt)
        if hour < 9 { earned.append(.earlyBird) }

        if playedInCarRecently { earned.append(.roadArtist) }

        return earned.filter { !alreadyEarned.contains($0) }
    }
}
