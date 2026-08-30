//
//  MealModeViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

@MainActor
@Observable
final class MealModeViewModel {
    let childProfile: ChildProfile

    var prompt: String? = nil
    var isLoading: Bool = false

    /// Bu sorunun konusu. Ebeveyn seçmiyor, uygulama sırayla dolaştırıyor.
    private(set) var category: MealPromptCategory = .table

    /// "Masada denedik" dendiğinde kazanılan rozetler.
    private(set) var awardedBadges: [MealBadge] = []
    private(set) var earnedBadges: Set<MealBadge> = []
    private(set) var totalAsked: Int = 0
    private(set) var isRecorded: Bool = false

    var tier: AgeTier { AgeTier.from(ageRange: childProfile.ageRange) }

    init(childProfile: ChildProfile) {
        self.childProfile = childProfile
        self.earnedBadges = MealStore.earnedBadges()
        self.totalAsked = MealStore.allRecords().count
    }

    func fetchNewPrompt() {
        isLoading = true
        awardedBadges = []
        isRecorded = false
        category = MealStore.nextCategory()

        Task {
            prompt = await MealService.fetchPrompt(
                ageRange: childProfile.ageRange,
                category: category,
                avoiding: MealStore.recentPrompts()
            )
            isLoading = false
        }
    }

    /// Ebeveyn soruyu masada sordu.
    ///
    /// Ekrandan kurtarılan süre defterine BİLEREK yazmıyoruz: çizimde
    /// başlangıç ve bitiş arasında ölçülen gerçek bir süre var, burada
    /// yok. Uydurma bir "5 dakika" yazmak o defteri güvenilmez yapardı.
    /// Meal Mode'un kazanımı rozet, dakika değil.
    func markAsked() {
        guard let prompt, !isRecorded else { return }
        let record = MealPromptRecord(prompt: prompt, category: category, tier: tier)
        awardedBadges = MealStore.record(record)
        earnedBadges = MealStore.earnedBadges()
        totalAsked = MealStore.allRecords().count
        isRecorded = true
    }
}
