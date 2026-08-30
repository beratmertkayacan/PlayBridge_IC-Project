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
/// Seçim ZORUNLU değil — yorgun bir ebeveyne bir adım daha eklemek
/// istemiyoruz. Seçilmezse backend eskisi gibi çalışıyor.
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

            FlowLayout(spacing: 10) {
                ForEach(viewModel.locationOptions, id: \.self) { location in
                    SelectableChip(
                        title: location,
                        isSelected: viewModel.selectedLocation == location
                    ) {
                        viewModel.toggleLocation(location)
                    }
                }
            }
        }
    }
}
