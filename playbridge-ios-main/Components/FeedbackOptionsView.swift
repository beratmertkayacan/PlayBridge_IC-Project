//
//  FeedbackOptionsView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// 5 geri bildirim seçeneği, tek dokunuşla seçilebilen çipler hâlinde.
///
/// Hem ana ekrandaki "nasıl gitti?" kartında hem de kütüphane detayında
/// aynı bileşen kullanılıyor — ebeveyn iki yerde de aynı şeyi görüyor.
struct FeedbackOptionsView: View {
    var selected: ActivityFeedback?
    let onSelect: (ActivityFeedback) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(ActivityFeedback.allCases) { option in
                chip(for: option)
            }
        }
    }

    private func chip(for option: ActivityFeedback) -> some View {
        let isSelected = selected == option
        // Olumlu geri bildirim marka rengiyle, olumsuzlar nötr bir tonla
        // vurgulanıyor — ebeveynin "kötü cevap verirsem ayıp olur" hissine
        // kapılmaması için hiçbiri kırmızı/uyarı rengi değil.
        let accent = option.isPositive ? Theme.primary : Theme.textSecondary

        return Button {
            onSelect(option)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.systemImage)
                    .font(.caption)
                Text(option.title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(isSelected ? accent : Theme.surface)
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : Theme.textSecondary.opacity(0.15),
                    lineWidth: 1
                )
            )
            .foregroundStyle(isSelected ? .white : Theme.textPrimary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
