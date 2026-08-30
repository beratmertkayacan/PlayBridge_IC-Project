//
//  MaterialsStepView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct MaterialsStepView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("What do you usually have nearby?")
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
                ForEach(viewModel.materialOptions, id: \.self) { material in
                    SelectableChip(
                        title: material,
                        isSelected: viewModel.selectedMaterials.contains(material)
                    ) {
                        viewModel.toggleMaterial(material)
                    }
                }
            }
            .padding(.horizontal, Theme.screenPadding)

            Spacer()
            Spacer()

            PrimaryButton(title: "Continue", isEnabled: viewModel.canContinueFromMaterials) {
                onContinue()
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.bottom, 24)
        }
    }
}
