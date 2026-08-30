//
//  DrawGameViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

@MainActor
@Observable
final class DrawGameViewModel {
    let childProfile: ChildProfile

    /// Ekranda gösterilen görev. Başlatılmış bir görev varsa o, yoksa
    /// havuzdan yeni seçilmiş biri.
    private(set) var challenge: DrawingChallenge?

    /// Görev başlatıldı mı? Başlatıldıysa ana ekrandaki bant "çizim
    /// bekleniyor" durumuna geçiyor.
    private(set) var active: ActiveChallenge?

    private(set) var weekCount: Int = 0
    private(set) var totalSketches: Int = 0
    private(set) var isSaving: Bool = false

    /// Kaydetme sonrası kazanılan rozetler — rozet anı ekranını bu tetikliyor.
    var awardedBadges: [SketchBadge] = []
    /// Rozet anı ekranında gösterilen çizim.
    var lastSavedEntry: SketchEntry?

    var tier: AgeTier { AgeTier.from(ageRange: childProfile.ageRange) }
    var weeklyGoal: Int { SketchStore.weeklyGoal }
    var isWeekComplete: Bool { weekCount >= weeklyGoal }
    var hasActiveChallenge: Bool { active != nil }

    init(childProfile: ChildProfile) {
        self.childProfile = childProfile
        refresh()
    }

    func refresh() {
        active = ActiveChallengeStore.load()
        weekCount = SketchStore.currentWeek().count
        totalSketches = SketchStore.allEntries().count

        if let active {
            challenge = active.challenge
        } else if challenge == nil {
            shuffle()
        }
    }

    /// Başka bir görev göster. Başlatılmış bir görev varken çalışmıyor —
    /// çocuk çizmeye başladıktan sonra görevi değiştirmek anlamsız.
    func shuffle() {
        guard active == nil else { return }
        challenge = ChallengeLibrary.random(
            for: tier,
            avoidingTexts: SketchStore.recentChallengeTexts()
        )
    }

    /// "Çizmeye başla" — süre ölçümü buradan itibaren işliyor.
    func startDrawing() {
        guard let challenge, active == nil else { return }
        ActiveChallengeStore.start(challenge)
        active = ActiveChallengeStore.load()
    }

    /// Ebeveyn vazgeçti — görev iptal, süre sayılmıyor.
    func cancelDrawing() {
        ActiveChallengeStore.clear()
        active = nil
        shuffle()
    }

    /// Fotoğrafı kaydeder, deftere işler, kazanılan rozetleri hazırlar.
    func save(image: UIImage) {
        guard let active, !isSaving else { return }
        isSaving = true

        guard let fileName = SketchPhotoStore.save(image) else {
            isSaving = false
            return
        }

        let entry = SketchEntry(
            challenge: active.challenge,
            photoFileName: fileName,
            screenFreeMinutes: active.elapsedMinutes
        )

        let badges = SketchStore.record(entry)
        ActiveChallengeStore.clear()

        // Çizim de bir aktivite: ekrandan kurtarılan süre TEK bir deftere
        // yazılıyor (Postgres'teki activity_logs). Oyun için paralel bir
        // sayaç tutmuyoruz — "bu hafta kurtarılan dakika" kartı hem
        // aktivitelerden hem çizimlerden besleniyor.
        logScreenTime(minutes: entry.screenFreeMinutes)

        lastSavedEntry = entry
        awardedBadges = badges
        self.active = nil
        challenge = nil
        isSaving = false
        refresh()
    }

    /// Backend'e yazamamak kullanıcı için bir hata değil: çizim zaten
    /// cihazda kayıtlı, rozet zaten verildi. Sunucu kapalıysa sadece
    /// haftalık toplam eksik kalır. ActivityResultViewModel ile aynı
    /// "sessizce devam et" davranışı.
    private func logScreenTime(minutes: Int) {
        Task {
            do {
                _ = try await ScreenTimeService.log(savedMinutes: minutes)
            } catch {
                print("Çizimin ekran süresi backend'e yazılamadı: \(error)")
            }
        }
    }
}
