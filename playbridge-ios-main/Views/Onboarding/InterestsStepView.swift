//
//  InterestsStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct InterestsStepView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("What does your child enjoy?")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("Pick as many as you like.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 40)
            .padding(.horizontal, Theme.screenPadding)

            Spacer()

            FlowLayout(spacing: 10) {
                ForEach(viewModel.interestOptions, id: \.self) { interest in
                    SelectableChip(
                        title: interest,
                        isSelected: viewModel.selectedInterests.contains(interest)
                    ) {
                        viewModel.toggleInterest(interest)
                    }
                }
            }
            .padding(.horizontal, Theme.screenPadding)

            Spacer()
            Spacer()

            PrimaryButton(title: "Continue", isEnabled: viewModel.canContinueFromInterests) {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }
}
