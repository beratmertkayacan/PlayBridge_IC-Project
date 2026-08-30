//
//  FeedbackPromptCard.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Ana ekranın en üstünde çıkan "geçen sefer nasıl gitti?" kartı.
///
/// Ürün kararı: burada ayrı bir ekrana ya da sheet'e GİTMİYORUZ. Yorgun
/// bir ebeveyn için her ekstra dokunuş cevaplanma oranını düşürür — 5
/// seçenek doğrudan kartın içinde, tek dokunuşla cevaplanıyor.
struct FeedbackPromptCard: View {
    let entry: PlayedActivity
    let onSelect: (ActivityFeedback) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How did it go?")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("\"\(entry.activity.title)\" — \(relativePlayedAt)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Not now")
            }

            FeedbackOptionsView(selected: nil, onSelect: onSelect)

            Text("One tap. It helps us suggest better ideas next time.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLarge).fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLarge)
                .strokeBorder(Theme.primary.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Theme.cardShadow, radius: 12, y: 6)
    }

    /// "yesterday", "2 days ago" gibi yumuşak bir zaman ifadesi.
    private var relativePlayedAt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: entry.playedAt, relativeTo: Date())
    }
}
