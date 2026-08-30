//
//  ScreenTimeSavedCard.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

struct ScreenTimeSavedCard: View {
    let viewModel: ScreenTimeViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 56, height: 56)
                Image(systemName: "hourglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("This week")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(0.4)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(viewModel.headline)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text(viewModel.unitLabel)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Text(viewModel.caption)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLarge)
                .fill(
                    LinearGradient(
                        colors: [Theme.primary, Theme.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Theme.primary.opacity(0.28), radius: 12, y: 6)
        .animation(.easeInOut(duration: 0.2), value: viewModel.savedMinutesThisWeek)
    }
}
