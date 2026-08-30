//
//  AgeRangeStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct AgeRangeStepView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("How old is your child?")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.textPrimary)
                    Text("This helps us suggest age-appropriate activities.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    ForEach(viewModel.ageRanges, id: \.self) { range in
                        AgeOptionButton(
                            title: range,
                            isSelected: viewModel.selectedAgeRange == range
                        ) {
                            viewModel.selectedAgeRange = range
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.screenPadding)

            Spacer()
            Spacer()

            PrimaryButton(title: "Continue", isEnabled: viewModel.canContinueFromAge) {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }
}

private struct AgeOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3.weight(.semibold))
                .frame(width: 84, height: 84)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium)
                        .fill(isSelected ? Theme.primary : Theme.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium)
                        .strokeBorder(isSelected ? Color.clear : Theme.textSecondary.opacity(0.15), lineWidth: 1)
                )
                .foregroundStyle(isSelected ? .white : Theme.textPrimary)
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? Theme.primary.opacity(0.25) : .clear, radius: 8, y: 4)
    }
}
