//
//  HomeViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum HomeMode: String, CaseIterable, Identifiable, Hashable {
    case need15Minutes
    case playTogether
    case mealMode
    case screenToPlay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .need15Minutes: return "I Need 15 Minutes"
        case .playTogether: return "Let's Play Together"
        case .mealMode: return "Meal Mode"
        case .screenToPlay: return "Turn Screen Into Play"
        }
    }

    var subtitle: String {
        switch self {
        case .need15Minutes: return "Independent play ideas"
        case .playTogether: return "Parent-child activity"
        case .mealMode: return "Screen-free conversation"
        case .screenToPlay: return "Transform content into imagination"
        }
    }

    var systemImage: String {
        switch self {
        case .need15Minutes: return "hourglass"
        case .playTogether: return "figure.2.and.child.holdinghands"
        case .mealMode: return "fork.knife"
        case .screenToPlay: return "sparkles.tv"
        }
    }
}

enum HomeRoute: Hashable {
    case needMinutes
    case playTogether
    case mealMode
    case screenToPlay
    /// Artık sadece üretilen aktiviteyi değil, onu ÜRETEN girdiyi de
    /// taşıyoruz — "Try a different idea" butonu yeniden üretim için
    /// bu girdiye ihtiyaç duyuyor.
    case activityResult(ActivityDraft)
}

@MainActor
@Observable
final class HomeViewModel {
    /// Ana ekranın üstünde "geçen sefer nasıl gitti?" diye sorulacak kayıt.
    /// Yoksa nil — kart hiç görünmüyor.
    private(set) var pendingFeedbackEntry: PlayedActivity?

    /// Geri bildirim verildikten sonra kısa bir teşekkür göstermek için.
    private(set) var justThanked: Bool = false

    /// "Sonraki açılışta sor" kuralı burada uygulanıyor: sadece BU
    /// açılıştan önce oynanmış kayıtlar soruluyor. Ebeveyn oyunu
    /// işaretledikten hemen sonra aynı oturumda soruyla karşılaşmıyor.
    func refreshPendingFeedback() {
        pendingFeedbackEntry = PlayLibraryStore.pendingFeedbackEntry(
            playedBefore: AppSession.launchedAt
        )
    }

    func submitFeedback(_ feedback: ActivityFeedback) {
        guard let entry = pendingFeedbackEntry else { return }
        PlayLibraryStore.saveFeedback(feedback, for: entry.id)
        pendingFeedbackEntry = nil
        justThanked = true

        // Teşekkür notu kalıcı olmasın: birkaç saniye sonra kendiliğinden
        // kayboluyor. Ana ekran "şu an neye ihtiyacın var?" ekranı olarak
        // kalmalı, geçmiş etkileşimin izini taşımamalı.
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            justThanked = false
        }
    }

    /// "Not now" — bu kayıt için bir daha sorulmuyor. (Kütüphane
    /// detayından istediği zaman yine puanlayabiliyor.)
    func dismissFeedback() {
        guard let entry = pendingFeedbackEntry else { return }
        PlayLibraryStore.dismissFeedbackRequest(for: entry.id)
        pendingFeedbackEntry = nil
    }
}
