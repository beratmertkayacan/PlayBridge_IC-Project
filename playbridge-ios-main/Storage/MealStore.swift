//
//  MealStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Meal Mode'un cihazdaki kaydı: sorulmuş sorular ve kazanılmış rozetler.
///
/// SketchStore'un küçük kardeşi — aynı felsefe, daha az parça. Haftalık
/// hedef YOK: yemek zaten her gün yeniyor, oraya bir hedef koymak
/// ebeveyne yerine getirilecek yeni bir görev yüklemek olurdu.
enum MealStore {
    private static let recordsKey = "playbridge.mealRecords"
    private static let badgesKey  = "playbridge.mealBadges"
    private static let recentMemory = 8

    static func allRecords() -> [MealPromptRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? JSONDecoder().decode([MealPromptRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.createdAt > $1.createdAt }
    }

    static func earnedBadges() -> Set<MealBadge> {
        guard let data = UserDefaults.standard.data(forKey: badgesKey),
              let badges = try? JSONDecoder().decode(Set<MealBadge>.self, from: data) else {
            return []
        }
        return badges
    }

    static func countsByCategory() -> [MealPromptCategory: Int] {
        allRecords().reduce(into: [:]) { result, record in
            result[record.category, default: 0] += 1
        }
    }

    static func recentPrompts() -> Set<String> {
        Set(allRecords().prefix(recentMemory).map(\.prompt))
    }

    /// Sıradaki kategori: en az sorulmuş olan.
    ///
    /// Rastgele seçmek yerine en az kullanılanı seçiyoruz — böylece
    /// "All Four Kinds" rozeti kendiliğinden ulaşılabilir hâle geliyor
    /// ve ebeveyn hep aynı tip soruyla karşılaşmıyor.
    static func nextCategory() -> MealPromptCategory {
        let counts = countsByCategory()
        return MealPromptCategory.allCases.min {
            (counts[$0] ?? 0, $0.rawValue) < (counts[$1] ?? 0, $1.rawValue)
        } ?? .table
    }

    /// Soruyu "masada denendi" olarak kaydeder, yeni rozetleri döner.
    @discardableResult
    static func record(_ record: MealPromptRecord) -> [MealBadge] {
        var records = allRecords()
        records.insert(record, at: 0)
        persistRecords(Array(records.prefix(200)))

        let already = earnedBadges()
        let newBadges = MealBadge.newlyEarned(
            total: records.count,
            countsByCategory: countsByCategory(),
            alreadyEarned: already
        )
        if !newBadges.isEmpty {
            persistBadges(already.union(newBadges))
        }
        return newBadges
    }

    /// Oturum sonlandırıldığında çağrılıyor: sorular ve rozetler sıfırlanıyor.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: recordsKey)
        UserDefaults.standard.removeObject(forKey: badgesKey)
    }

    private static func persistRecords(_ records: [MealPromptRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    private static func persistBadges(_ badges: Set<MealBadge>) {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: badgesKey)
        }
    }
}
