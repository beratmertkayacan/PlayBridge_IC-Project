//
//  MaterialsSection.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// "What do you have available right now?" bölümü.
///
/// Hazır çipler + ebeveynin elle eklediği çipler AYNI FlowLayout içinde
/// akıyor — bilinçli bir karar: ebeveyn için "listeden seçtiğim" ile
/// "kendim yazdığım" arasında bir fark yok, ikisi de elinde olan şey.
/// Altındaki TextField, listeyi uzatmak yerine listeyi genişletiyor.
///
/// İki giriş ekranı (Need 15 Minutes / Play Together) bu bileşeni
/// paylaşıyor; malzeme listesi de burada tek nüsha duruyor.
struct MaterialsSection: View {
    @Bindable var viewModel: ActivityGeneratorViewModel

    static let defaultOptions = [
        "Paper", "Crayons", "Building Blocks", "Toy Animals", "Books", "Pillows", "Ball"
    ]

    var options: [String] = MaterialsSection.defaultOptions

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What do you have available right now?")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if viewModel.allowsEmptyMaterials {
                Text("In the car this is optional. Leave it empty for a looking game from the windows, like counting red cars or spotting a truck.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FlowLayout(spacing: 10) {
                if viewModel.allowsEmptyMaterials {
                    SelectableChip(
                        title: "Nothing in hand",
                        isSelected: viewModel.nothingInHand
                    ) {
                        viewModel.clearMaterials()
                    }
                }

                ForEach(viewModel.visibleMaterialChips, id: \.self) { material in
                    SelectableChip(
                        title: material,
                        isSelected: viewModel.selectedMaterials.contains(material)
                    ) {
                        viewModel.toggleMaterial(material)
                    }
                }

                ForEach(viewModel.customMaterials, id: \.self) { material in
                    RemovableChip(title: material) {
                        viewModel.removeCustomMaterial(material)
                    }
                }
            }

            manualInputRow
        }
    }

    private var manualInputRow: some View {
        HStack(spacing: 10) {
            TextField("Something else? e.g. cardboard box", text: $viewModel.manualMaterialInput)
                .textFieldStyle(.plain)
                .font(.body)
                .autocorrectionDisabled()
                .submitLabel(.done)
                // Klavyedeki "done" ile de eklenebilsin — ebeveynin
                // "+" düğmesini bulmak zorunda kalmaması için.
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
}
