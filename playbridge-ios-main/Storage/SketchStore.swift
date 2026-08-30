//
//  SketchStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Haftalık hedefin durumu.
struct SketchWeekState: Codable, Hashable {
    var weekStart: Date
    var count: Int
    var consecutiveFullWeeks: Int
    var lastFullWeekStart: Date?
}

/// Çizim defterinin cihazdaki kaydı: çizimler, rozetler, haftalık durum.
///
/// ProfileStore ve PlayLibraryStore ile aynı felsefe — her şey
/// UserDefaults'ta, hiçbir veri cihazdan çıkmıyor. Fotoğrafların
/// kendisi burada değil, SketchPhotoStore'da dosya olarak duruyor.
enum SketchStore {
    private static let entriesKey = "playbridge.sketchEntries"
    private static let badgesKey  = "playbridge.sketchBadges"
    private static let weekKey    = "playbridge.sketchWeek"

    /// Haftalık hedef. Ulaşılamazsa hiçbir şey kaybolmuyor — bu bir
    /// hedef, bir borç değil.
    static let weeklyGoal = 3

    /// Görev tekrarını önlemek için hatırlanan son görev sayısı.
    private static let recentMemory = 12

    // MARK: - Okuma

    /// Tüm çizimler, en yeni başta.
    static func allEntries() -> [SketchEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let entries = try? JSONDecoder().decode([SketchEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.createdAt > $1.createdAt }
    }

    static func earnedBadges() -> Set<SketchBadge> {
        guard let data = UserDefaults.standard.data(forKey: badgesKey),
              let badges = try? JSONDecoder().decode(Set<SketchBadge>.self, from: data) else {
            return []
        }
        return badges
    }

    /// Bu haftanın durumu. Hafta değiştiyse sayaç sıfırlanmış hâlini döner.
    static func currentWeek() -> SketchWeekState {
        let thisWeekStart = startOfWeek(for: Date())
        guard let data = UserDefaults.standard.data(forKey: weekKey),
              var state = try? JSONDecoder().decode(SketchWeekState.self, from: data) else {
            return SketchWeekState(weekStart: thisWeekStart, count: 0, consecutiveFullWeeks: 0, lastFullWeekStart: nil)
        }
        if state.weekStart != thisWeekStart {
            // Yeni hafta: sayaç sıfırlanıyor. Geçen hafta dolmadıysa
            // HİÇBİR ŞEY olmuyor — uyarı yok, kayıp yok, bildirim yok.
            state.weekStart = thisWeekStart
            state.count = 0
        }
        return state
    }

    /// Son kullanılan görev metinleri — aynı görevin tekrar gelmemesi için.
    static func recentChallengeTexts() -> Set<String> {
        Set(allEntries().prefix(recentMemory).map(\.challengeText))
    }

    // MARK: - Özetler

    static var totalPoints: Int { allEntries().reduce(0) { $0 + $1.points } }

    /// Ekrandan uzakta geçen toplam dakika. Ölçülen değerlerin toplamı,
    /// tahmin değil — ürünün asıl vaadinin tek sayısal karşılığı.
    static var totalScreenFreeMinutes: Int { allEntries().reduce(0) { $0 + $1.screenFreeMinutes } }

    static func countsByCategory() -> [SketchCategory: Int] {
        allEntries().reduce(into: [:]) { result, entry in
            result[entry.category, default: 0] += 1
        }
    }

    // MARK: - Yazma

    /// Yeni bir çizimi deftere işler ve bu kayıtla kazanılan rozetleri döner.
    @discardableResult
    static func record(_ entry: SketchEntry) -> [SketchBadge] {
        var entries = allEntries()
        let previousDate = entries.first?.createdAt
        entries.insert(entry, at: 0)
        persistEntries(entries)

        var week = currentWeek()
        week.count += 1

        // Hedef bu kayıtla dolduysa, üst üste dolan hafta sayısını güncelle.
        if week.count == weeklyGoal {
            let previousWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: week.weekStart)
            if let last = week.lastFullWeekStart, last == previousWeekStart {
                week.consecutiveFullWeeks += 1
            } else {
                week.consecutiveFullWeeks = 1
            }
            week.lastFullWeekStart = week.weekStart
        }
        persistWeek(week)

        let context = BadgeContext(
            totalSketches: entries.count,
            countsByCategory: countsByCategory(),
            sketchesThisWeek: week.count,
            weeklyGoal: weeklyGoal,
            consecutiveFullWeeks: week.consecutiveFullWeeks,
            daysSincePreviousSketch: previousDate.map {
                Calendar.current.dateComponents([.day], from: $0, to: entry.createdAt).day ?? 0
            },
            createdAt: entry.createdAt,
            playedInCarRecently: playedInCarRecently()
        )

        let already = earnedBadges()
        let newBadges = context.newlyEarned(alreadyEarned: already)
        if !newBadges.isEmpty {
            persistBadges(already.union(newBadges))
        }
        return newBadges
    }

    /// Oturum sonlandırıldığında çağrılıyor.
    ///
    /// Kayıtlarla birlikte FOTOĞRAFLARI da siliyor — kayıt silinip
    /// görüntü diskte kalırsa hem yer işgal eder hem de "her şey
    /// silindi" sözünü tutmamış oluruz.
    static func clearAll() {
        for entry in allEntries() {
            SketchPhotoStore.delete(entry.photoFileName)
        }
        UserDefaults.standard.removeObject(forKey: entriesKey)
        UserDefaults.standard.removeObject(forKey: badgesKey)
        UserDefaults.standard.removeObject(forKey: weekKey)
        SketchPhotoStore.deleteAll()
    }

    static func delete(_ entry: SketchEntry) {
        SketchPhotoStore.delete(entry.photoFileName)
        persistEntries(allEntries().filter { $0.id != entry.id })
    }

    // MARK: - Yardımcılar

    /// Son bir saat içinde "In the car" seçilerek oynanmış bir aktivite
    /// var mı? Road Artist rozeti bunun üstüne kurulu — iki özelliğin
    /// verisinin birbirini beslediği tek nokta.
    private static func playedInCarRecently() -> Bool {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return PlayLibraryStore.all().contains { played in
            guard played.playedAt > oneHourAgo else { return false }
            if case .generated(let request) = played.source {
                return request.location == "In the car"
            }
            return false
        }
    }

    /// Haftanın başlangıcı. Pazartesi sabahı — Türkiye ve Avrupa'daki
    /// hafta algısıyla uyumlu olsun diye takvimden bağımsız sabitliyoruz.
    private static func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    private static func persistEntries(_ entries: [SketchEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
    }

    private static func persistBadges(_ badges: Set<SketchBadge>) {
        if let data = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(data, forKey: badgesKey)
        }
    }

    private static func persistWeek(_ state: SketchWeekState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: weekKey)
        }
    }
}
