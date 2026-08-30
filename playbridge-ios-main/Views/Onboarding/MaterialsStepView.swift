//
//  MaterialsStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct MaterialsStepView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("What do you usually have nearby?")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("Start with the room you are in. Pick what is already at hand, or type your own.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 28)
            .padding(.horizontal, Theme.screenPadding)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    categoryRow

                    if !viewModel.selectedMaterials.isEmpty {
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

            PrimaryButton(title: "Continue", isEnabled: viewModel.canContinueFromMaterials) {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }

    private var categoryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WHERE")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MaterialCategory.allCases) { category in
                        SelectableChip(
                            title: category.title,
                            isSelected: viewModel.selectedMaterialCategory == category
                        ) {
                            viewModel.selectedMaterialCategory = category
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
                ForEach(viewModel.sortedSelectedMaterials, id: \.self) { material in
                    if viewModel.customMaterials.contains(material) {
                        RemovableChip(title: material) {
                            viewModel.removeCustomMaterial(material)
                        }
                    } else {
                        SelectableChip(title: material, isSelected: true) {
                            viewModel.toggleMaterial(material)
                        }
                    }
                }
            }
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.selectedMaterialCategory.title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            FlowLayout(spacing: 10) {
                ForEach(viewModel.visibleMaterialOptions, id: \.self) { material in
                    SelectableChip(
                        title: material,
                        isSelected: viewModel.selectedMaterials.contains(material)
                    ) {
                        viewModel.toggleMaterial(material)
                    }
                }
            }
        }
    }

    private var manualInputRow: some View {
        HStack(spacing: 10) {
            TextField("Something else? e.g. cardboard box", text: $viewModel.manualMaterialInput)
                .textFieldStyle(.plain)
                .font(.body)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit { viewModel.addManualMaterial() }
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
                viewModel.addManualMaterial()
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusMedium)
                            .fill(viewModel.canAddManualMaterial ? Theme.primary : Theme.surfaceSelected)
                    )
                    .foregroundStyle(viewModel.canAddManualMaterial ? .white : Theme.textSecondary)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canAddManualMaterial)
            .animation(.easeInOut(duration: 0.15), value: viewModel.canAddManualMaterial)
            .accessibilityLabel("Add material")
        }
    }

    private var pickedHeadline: String {
        let count = viewModel.selectedMaterials.count
        return count == 1 ? "1 NEARBY" : "\(count) NEARBY"
    }
}
