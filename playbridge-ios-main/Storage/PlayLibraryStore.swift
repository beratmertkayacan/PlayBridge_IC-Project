//
//  PlayLibraryStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Oynanmış aktivitelerin cihazdaki defteri.
///
/// ProfileStore ile aynı felsefe: her şey UserDefaults'ta, cihazdan
/// hiçbir veri çıkmıyor. Ürünün gizlilik duruşu ("adı, fotoğrafı, tam
/// yaşı istemiyoruz") geri bildirim verisi için de aynen geçerli.
///
/// Not: UserDefaults büyük listeler için ideal değil, bu yüzden kayıt
/// sayısını `maxEntries` ile sınırlıyoruz. Kütüphane bir arşiv değil,
/// yakın geçmişin defteri.
enum PlayLibraryStore {
    private static let key = "playbridge.playLibrary"
    private static let maxEntries = 100

    // MARK: - Okuma

    /// Tüm kayıtlar, en yeni oynanan başta.
    static func all() -> [PlayedActivity] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([PlayedActivity].self, from: data) else {
            return []
        }
        return entries.sorted { $0.playedAt > $1.playedAt }
    }

    /// Ana ekranda "geçen sefer nasıl gitti?" diye sorulacak kayıt.
    ///
    /// `before` parametresi "sonraki açılışta sor" kuralını uyguluyor:
    /// buraya bu açılışın başlangıç zamanı veriliyor, yani ebeveyn
    /// oyunu işaretledikten hemen sonra aynı oturumda soru sorulmuyor.
    /// Ancak uygulamayı bir daha açtığında — oyun gerçekten oynandıktan
    /// sonra — karşısına çıkıyor.
    static func pendingFeedbackEntry(playedBefore date: Date) -> PlayedActivity? {
        all().first { $0.awaitsFeedback && $0.playedAt < date }
    }

    // MARK: - Yazma

    /// Aktiviteyi "oynandı" olarak kaydeder. Kütüphaneye giren TEK yol bu.
    @discardableResult
    static func recordPlayed(activity: PlayActivity, source: ActivitySource) -> PlayedActivity {
        var entries = all()
        let entry = PlayedActivity(activity: activity, source: source)

        // Aynı aktivite tekrar oynandıysa çift kayıt bırakma, tarihini tazele.
        entries.removeAll { $0.id == entry.id }
        entries.insert(entry, at: 0)

        persist(Array(entries.prefix(maxEntries)))
        return entry
    }

    static func saveFeedback(_ feedback: ActivityFeedback, for id: String) {
        update(id) { entry in
            entry.feedback = feedback
            entry.feedbackAt = Date()
            entry.feedbackDismissed = false
        }
    }

    /// Ebeveyn "Not now" dedi — bu kayıt için bir daha ana ekranda sorma.
    static func dismissFeedbackRequest(for id: String) {
        update(id) { $0.feedbackDismissed = true }
    }

    static func delete(id: String) {
        persist(all().filter { $0.id != id })
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Bu hafta (Pazartesi 00:00 UTC) kütüphaneye giren oyunların toplam süresi.
    /// Backend ulaşılamazsa kart yine de boş kalmasın diye.
    static func minutesSavedThisWeek(now: Date = Date()) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday + 5) % 7
        guard let start = calendar.date(byAdding: .day, value: -daysFromMonday, to: now) else {
            return 0
        }
        let weekStart = calendar.startOfDay(for: start)
        return all()
            .filter { $0.playedAt >= weekStart }
            .reduce(0) { $0 + $1.activity.activityTimeMinutes }
    }

    // MARK: - Yardımcılar

    private static func update(_ id: String, _ change: (inout PlayedActivity) -> Void) {
        var entries = all()
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        change(&entries[index])
        persist(entries)
    }

    private static func persist(_ entries: [PlayedActivity]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
