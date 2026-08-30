//
//  LocationSection.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// "Where are you right now?" bölümü.
///
/// Ürün açısından bu, süreden sonraki en belirleyici girdi: arabadaki
/// bir ebeveynle oturma odasındaki ebeveyn aynı öneriyi alamaz. Arabada
/// yere yayılan, yuvarlanıp kaçan, masa isteyen hiçbir oyun işe yaramaz.
///
/// Seçim zorunlu değil. Açılır menü yorgun ebeveynin tek dokunuşla
/// yer seçmesini sağlar; Skip ile boş bırakılabilir.
struct LocationSection: View {
    @Bindable var viewModel: ActivityGeneratorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Where are you right now?")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("optional")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Menu {
                Button("Skip for now") {
                    viewModel.selectLocation(nil)
                }
                ForEach(viewModel.locationOptions, id: \.self) { location in
                    Button(location) {
                        viewModel.selectLocation(location)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(viewModel.selectedLocation ?? "Choose a place")
                        .font(.body)
                        .foregroundStyle(
                            viewModel.selectedLocation == nil
                                ? Theme.textSecondary
                                : Theme.textPrimary
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium).fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMedium)
                        .strokeBorder(
                            viewModel.selectedLocation == nil
                                ? Theme.textSecondary.opacity(0.15)
                                : Theme.primary.opacity(0.35),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}
