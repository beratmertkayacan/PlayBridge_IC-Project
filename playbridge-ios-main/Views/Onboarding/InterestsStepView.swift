//
//  InterestsStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct InterestsStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("What does your child enjoy?")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("Pick a category, then tap what fits. You can also type your own.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 28)
            .padding(.horizontal, Theme.screenPadding)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    categoryRow

                    if !viewModel.selectedInterests.isEmpty {
                        pickedSection
                    }

                    optionsSection
                    manualInputRow
                }
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(title: "Continue", isEnabled: viewModel.canContinueFromInterests) {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }

    private var categoryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORY")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(InterestCategory.allCases) { category in
                        SelectableChip(
                            title: category.title,
                            isSelected: viewModel.selectedInterestCategory == category
                        ) {
                            viewModel.selectedInterestCategory = category
                        }
                    }
                }
            }
        }
    }

    private var pickedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pickedHeadline)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            FlowLayout(spacing: 10) {
                ForEach(viewModel.sortedSelectedInterests, id: \.self) { interest in
                    if viewModel.customInterests.contains(interest) {
                        RemovableChip(title: interest) {
                            viewModel.removeCustomInterest(interest)
                        }
                    } else {
                        SelectableChip(title: interest, isSelected: true) {
                            viewModel.toggleInterest(interest)
                        }
                    }
                }
            }
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.selectedInterestCategory.title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            FlowLayout(spacing: 10) {
                ForEach(viewModel.visibleInterestOptions, id: \.self) { interest in
                    SelectableChip(
                        title: interest,
                        isSelected: viewModel.selectedInterests.contains(interest)
                    ) {
                        viewModel.toggleInterest(interest)
                    }
                }
            }
        }
    }

    private var manualInputRow: some View {
        HStack(spacing: 10) {
            TextField("Something else? e.g. ballet, trains", text: $viewModel.manualInterestInput)
                .textFieldStyle(.plain)
                .font(.body)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit { viewModel.addManualInterest() }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium).fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium)
                        .strokeBorder(Theme.textSecondary.opacity(0.15), lineWidth: 1)
                )

            Button {
                viewModel.addManualInterest()
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMedium)
                            .fill(viewModel.canAddManualInterest ? Theme.primary : Theme.surfaceSelected)
                    )
                    .foregroundStyle(viewModel.canAddManualInterest ? .white : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canAddManualInterest)
            .animation(.easeInOut(duration: 0.15), value: viewModel.canAddManualInterest)
            .accessibilityLabel("Add interest")
        }
    }

    private var pickedHeadline: String {
        let count = viewModel.selectedInterests.count
        return count == 1 ? "1 PICKED" : "\(count) PICKED"
    }
}
