//
//  MinutesInputSection.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Süre / kurulum dakikası: hazır çipler + elle sayı girişi.
struct MinutesInputSection: View {
    let title: String
    let options: [Int]
    let selected: Int?
    let extraChip: Int?
    let placeholder: String
    @Binding var manualInput: String
    let canAdd: Bool
    let onSelect: (Int) -> Void
    let onAddManual: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            FlowLayout(spacing: 10) {
                ForEach(options, id: \.self) { minutes in
                    SelectableChip(
                        title: "\(minutes) min",
                        isSelected: selected == minutes
                    ) {
                        onSelect(minutes)
                    }
                }

                if let extraChip {
                    SelectableChip(
                        title: "\(extraChip) min",
                        isSelected: selected == extraChip
                    ) {
                        onSelect(extraChip)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField(placeholder, text: $manualInput)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    .onSubmit { onAddManual() }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMedium).fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMedium)
                            .strokeBorder(Theme.textSecondary.opacity(0.15), lineWidth: 1)
                    )

                Button(action: onAddManual) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .frame(width: 46, height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.radiusMedium)
                                .fill(canAdd ? Theme.primary : Theme.surfaceSelected)
                        )
                        .foregroundStyle(canAdd ? .white : Theme.textSecondary)
                }
                .buttonStyle(.plain)
                .disabled(!canAdd)
                .animation(.easeInOut(duration: 0.15), value: canAdd)
                .accessibilityLabel("Add minutes")
            }
        }
    }
}
