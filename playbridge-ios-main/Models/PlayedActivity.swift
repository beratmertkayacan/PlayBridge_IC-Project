//
//  PlayedActivity.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Bir aktivitenin hangi girdiden üretildiği.
///
/// İki işi birden yapıyor:
/// 1. "Try a different idea" butonu, aktiviteyi hangi girdiyle yeniden
///    üreteceğini buradan biliyor.
/// 2. Kütüphanedeki kayıt, hangi moddan geldiğini buradan etiketliyor.
enum ActivitySource: Codable, Hashable {
    /// "I Need 15 Minutes" ve "Let's Play Together" — ikisi de aynı
    /// ActivityRequest'i kullanıyor, farkı içindeki `mode` alanı.
    case generated(ActivityRequest)
    /// "Turn Screen Into Play" — ekran konusundan üretiliyor.
    case screenToPlay(ageRange: String, topic: String)

    /// Kütüphane satırında gösterilen mod rozeti.
    var modeLabel: String {
        switch self {
        case .generated(let request):
            return request.mode == "together" ? "Together" : "Independent"
        case .screenToPlay:
            return "Screen to Play"
        }
    }

    var modeSystemImage: String {
        switch self {
        case .generated(let request):
            return request.mode == "together" ? "figure.2.and.child.holdinghands" : "hourglass"
        case .screenToPlay:
            return "sparkles.tv"
        }
    }
}

/// Sonuç ekranına taşınan paket: üretilen aktivite + onu üreten girdi.
///
/// NavigationPath'e bu değer konuyor, bu yüzden Hashable olmak zorunda.
struct ActivityDraft: Codable, Hashable {
    var response: GeneratedActivityResponse
    var source: ActivitySource
}

/// Kütüphanedeki bir kayıt — yani ebeveynin GERÇEKTEN oynadığını
/// işaretlediği bir aktivite.
///
/// Önemli kural: buraya sadece "Put the phone down & play" denen
/// aktiviteler giriyor. "Try a different idea" ile atılan öneriler
/// hiç kaydedilmiyor — kütüphane bir öneri çöplüğü değil, gerçekten
/// oynanmış oyunların defteri.
struct PlayedActivity: Codable, Identifiable, Hashable {
    var id: String
    var activity: PlayActivity
    var source: ActivitySource
    var playedAt: Date

    /// Ebeveyn henüz değerlendirmediyse nil.
    var feedback: ActivityFeedback?
    var feedbackAt: Date?

    /// Ebeveyn "Not now" dediyse true — ana ekranda bir daha sorulmuyor.
    /// (Kütüphane detayından istediği zaman yine puanlayabiliyor.)
    var feedbackDismissed: Bool = false

    init(
        activity: PlayActivity,
        source: ActivitySource,
        playedAt: Date = Date(),
        feedback: ActivityFeedback? = nil,
        feedbackAt: Date? = nil,
        feedbackDismissed: Bool = false
    ) {
        self.id = activity.id
        self.activity = activity
        self.source = source
        self.playedAt = playedAt
        self.feedback = feedback
        self.feedbackAt = feedbackAt
        self.feedbackDismissed = feedbackDismissed
    }

    /// Ana ekranda "nasıl gitti?" diye sorulmaya uygun mu?
    var awaitsFeedback: Bool {
        feedback == nil && !feedbackDismissed
    }
}
