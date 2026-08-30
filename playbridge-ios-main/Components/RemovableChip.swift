//
//  RemovableChip.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Ebeveynin elle yazdığı malzemeler için çip.
///
/// SelectableChip'ten farkı: bu her zaman "seçili" — çünkü ebeveyn onu
/// zaten bilerek yazdı. Dokunuş seçmeyi değil SİLMEYİ tetikliyor, bu
/// yüzden sağında bir ✕ var. Görsel dili SelectableChip'in seçili
/// hâliyle birebir aynı tutuyoruz ki liste tek parça görünsün.
struct RemovableChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .opacity(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Theme.primary))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .shadow(color: Theme.primary.opacity(0.25), radius: 6, y: 3)
        .accessibilityLabel("Remove \(title)")
    }
}
