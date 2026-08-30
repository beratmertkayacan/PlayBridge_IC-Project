//
//  WelcomeStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct WelcomeStepView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.primary)
            }
            .padding(.bottom, 28)

            Text("PlayBridge AI")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.textPrimary)

            Text("From Screen Time to Play Time.")
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 4)

            Text("PlayBridge helps parents turn passive screen moments into simple, age-appropriate real-world play.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 36)
                .padding(.top, 16)

            Spacer()
            Spacer()

            PrimaryButton(title: "Get Started") {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }
}
