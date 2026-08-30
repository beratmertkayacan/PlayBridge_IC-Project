//
//  BadgeStamp.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Rozetin görsel karşılığı: mürekkep damgası.
///
/// Konfeti ya da havai fişek yerine damga seçtik — uygulamanın krem-yeşil
/// dili sakin, ödül anı da sakin olmalı. Damga aynı zamanda "deftere
/// işlendi" hissini veriyor ki oyunun tamamı bunun üstüne kurulu.
struct BadgeStamp: View {
    /// Yalnızca sembol adını tutuyoruz — böylece hem çizim hem yemek
    /// rozetleri aynı damgayı kullanabiliyor, ikinci bir bileşen
    /// yazmaya gerek kalmıyor.
    let systemImage: String
    var size: CGFloat = 96
    var isEarned: Bool = true

    init(systemImage: String, size: CGFloat = 96, isEarned: Bool = true) {
        self.systemImage = systemImage
        self.size = size
        self.isEarned = isEarned
    }

    init(badge: SketchBadge, size: CGFloat = 96, isEarned: Bool = true) {
        self.init(systemImage: badge.systemImage, size: size, isEarned: isEarned)
    }

    init(badge: MealBadge, size: CGFloat = 96, isEarned: Bool = true) {
        self.init(systemImage: badge.systemImage, size: size, isEarned: isEarned)
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                .foregroundStyle(color.opacity(isEarned ? 0.55 : 0.25))
            Circle()
                .fill(color.opacity(isEarned ? 0.12 : 0.05))
                .padding(5)
            Image(systemName: systemImage)
                .font(.system(size: size * 0.34))
                .foregroundStyle(color.opacity(isEarned ? 1 : 0.3))
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(-6))
    }

    private var color: Color { Theme.primary }
}
