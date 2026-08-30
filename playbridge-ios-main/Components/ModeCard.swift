//
//  ModeCard.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct ModeCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(Theme.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusLarge).fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusLarge)
                    .strokeBorder(Theme.textSecondary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Theme.cardShadow, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
