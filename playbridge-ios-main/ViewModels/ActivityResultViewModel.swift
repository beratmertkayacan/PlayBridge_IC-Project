//
//  ActivityResultViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Sonuç ekranının durumu.
///
/// İki yeni davranışın sahibi:
/// 1. "Suggest another one" — aynı girdiyle (süre, mekan, malzemeler)
///    yeni bir aktivite üretir, ekranı yerinde değiştirir. Yeni bir
///    ekrana GİTMİYORUZ: ebeveyn
///    geri tuşuyla eski önerilere dönmek istemez, tek bir öneri görmek
///    ister. Atılan öneri hiçbir yere kaydedilmez.
/// 2. "Put the phone down & play" — aktiviteyi kütüphaneye "oynandı"
///    olarak yazar. Kütüphaneye giren tek yol budur.
@MainActor
@Observable
final class ActivityResultViewModel {
    private(set) var response: GeneratedActivityResponse
    let source: ActivitySource

    var isRegenerating: Bool = false

    /// Kaç kez alternatif istendi — ekranda küçük bir ipucu göstermek için.
    private(set) var alternativeCount: Int = 0

    var activity: PlayActivity { response.activity }

    init(draft: ActivityDraft) {
        self.response = draft.response
        self.source = draft.source
    }

    func regenerate() {
        guard !isRegenerating else { return }
        isRegenerating = true
        Task {
            let newResponse: GeneratedActivityResponse
            switch source {
            case .generated(let request):
                newResponse = await ActivityService.generateActivity(for: request)
            case .screenToPlay(let ageRange, let topic):
                newResponse = await ScreenToPlayService.generateActivity(
                    ageRange: ageRange,
                    screenTopic: topic
                )
            }
            response = newResponse
            alternativeCount += 1
            isRegenerating = false
        }
    }

    func markAsPlayed() {
        PlayLibraryStore.recordPlayed(activity: activity, source: source)
    }
}
