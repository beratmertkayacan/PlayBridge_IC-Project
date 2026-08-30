//
//  PlayedActivityDetailView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Kütüphanedeki bir kaydın detayı.
///
/// İki iş yapıyor:
/// 1. Oyunu ilk gördüğü hâliyle tekrar gösteriyor — ebeveyn beğendiği
///    bir oyunu yeniden üretmeden, tek dokunuşla tekrar oynayabiliyor.
///    (Kütüphanenin asıl değeri burası.)
/// 2. Geri bildirimi burada da verilebiliyor/değiştirilebiliyor — ana
///    ekrandaki soruyu kaçırdıysa ya da fikri değiştiyse.
struct PlayedActivityDetailView: View {
    let entry: PlayedActivity
    let viewModel: PlayLibraryViewModel

    /// Geri bildirim değişince ekranın güncel kalması için kaydı her
    /// seferinde ViewModel'den okuyoruz.
    private var current: PlayedActivity {
        viewModel.entries.first { $0.id == entry.id } ?? entry
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: current.source.modeSystemImage)
                                .font(.caption)
                                .foregroundStyle(Theme.primary)
                            Text(current.source.modeLabel.uppercased())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Theme.textSecondary)
                                .tracking(0.5)
                        }

                        Text(current.activity.title)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Theme.textPrimary)

                        Text("Played \(longDate(current.playedAt))")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    ActivityBodyView(activity: current.activity)

                    feedbackSection
                }
                .padding(Theme.screenPadding)
            }
        }
        .navigationTitle("From your library")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(current.feedback == nil ? "HOW DID IT GO?" : "YOUR RATING")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            FeedbackOptionsView(selected: current.feedback) { feedback in
                viewModel.setFeedback(feedback, for: current)
            }

            if current.feedback != nil {
                Text("Tap another option to change it.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, 8)
    }

    private func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
