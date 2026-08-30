//
//  PrivacyStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct PrivacyStepView: View {
    let viewModel: OnboardingViewModel
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.primary)
            }

            Text("Your child's privacy comes first")
                .font(.title2.bold())
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 14) {
                PrivacyPoint(text: "PlayBridge does not need your child's name, photo or exact location.")
                PrivacyPoint(text: "AI suggestions are generated for parents and should be reviewed before use.")
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer()

            PrimaryButton(title: "Continue") {
                onFinish()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }
}

private struct PrivacyPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.primary)
                .font(.body)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
