//
//  DrawGameBanner.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Ana ekrandaki çizim oyunu şeridi.
///
/// Mod kartlarının ALTINDA duruyor. Sebebi ürünle ilgili: "Şu an neye
/// ihtiyacın var?" acil sorusu her zaman ilk sırada kalmalı. Oyun bir
/// bonus, bir manşet değil.
struct DrawGameBanner: View {
    let weekCount: Int
    let weeklyGoal: Int
    let hasActiveChallenge: Bool
    let activeChallengeText: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "pencil.and.outline")
                        .font(.subheadline)
                        .foregroundStyle(Theme.primary)
                    Text("DRAW & COLLECT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.8)
                    Spacer()
                    weekRings
                }

                if hasActiveChallenge, let activeChallengeText {
                    Text(activeChallengeText)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    label("Save the drawing", systemImage: "camera")
                } else {
                    Text("Today's drawing challenge")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    label(
                        weekCount >= weeklyGoal
                            ? "This week is full — draw anyway"
                            : "\(weeklyGoal - weekCount) more this week",
                        systemImage: "arrow.right"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLarge).fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusLarge)
                    .strokeBorder(
                        hasActiveChallenge ? Theme.primary.opacity(0.35) : Theme.textSecondary.opacity(0.08),
                        lineWidth: 1
                    )
            )
            .shadow(color: Theme.cardShadow, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    /// Haftalık hedefin görsel karşılığı. Dolmayan halka bir eksiklik
    /// değil, sadece boş bir halka — kırmızı yok, uyarı yok.
    private var weekRings: some View {
        HStack(spacing: 5) {
            ForEach(0..<weeklyGoal, id: \.self) { index in
                Circle()
                    .fill(index < weekCount ? Theme.primary : Theme.surfaceSelected)
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func label(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline.weight(.medium))
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Theme.primary)
    }
}
