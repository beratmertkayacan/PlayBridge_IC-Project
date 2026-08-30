//
//  SelectableChip.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(isSelected ? Theme.primary : Theme.surface)
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
        .shadow(color: isSelected ? Theme.primary.opacity(0.25) : .clear, radius: 6, y: 3)
    }
}
