//
//  ActivityBodyView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Bir aktivitenin gövdesi: rozetler + "Why it fits", "You'll need",
/// "Set it up", "Try this", "Keep the story going" bölümleri.
///
/// Aynı gövde iki yerde gösteriliyor — yeni üretilen aktivitede
/// (ActivityResultView) ve kütüphanedeki kayıtta (PlayedActivityDetailView).
/// Ebeveynin kütüphaneden açtığı oyun, ilk gördüğü hâlin birebir aynısı
/// olmalı; bu yüzden tek bir yerde duruyor.
struct ActivityBodyView: View {
    let activity: PlayActivity

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            badgeRow

            section(title: "WHY IT FITS") {
                Text(activity.summary)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
            }

            section(title: "YOU'LL NEED") {
                FlowLayout(spacing: 10) {
                    ForEach(activity.materials, id: \.self) { material in
                        SelectableChip(title: material, isSelected: true) {}
                    }
                }
            }

            section(title: "SET IT UP") {
                numberedList(activity.setupSteps)
            }

            section(title: "TRY THIS") {
                numberedList(activity.childInstructions)
            }

            section(title: "KEEP THE STORY GOING") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(activity.imaginationPrompts, id: \.self) { prompt in
                        Text("• \(prompt)")
                            .font(.body)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
    }

    private var badgeRow: some View {
        HStack(spacing: 10) {
            badge("\(activity.setupTimeMinutes) min setup")
            badge("\(activity.activityTimeMinutes) min play")
            badge(activity.screenRequired ? "Screen" : "No screen")
        }
    }

    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.primary.opacity(0.12))
            .foregroundStyle(Theme.primary)
            .clipShape(Capsule())
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)
            content()
        }
    }

    private func numberedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                    Text(item)
                        .font(.body)
                        .foregroundStyle(Theme.textPrimary)
                }
            }
        }
    }
}
