//
//  BadgeMomentView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Çocuğun uygulamayı gördüğü TEK an.
///
/// Bu yüzden tek amaçlı: çizimi göster, damgayı bas, kapan. Buton yok,
/// menü yok, gidilecek başka yer yok. Birkaç saniye sonra kendiliğinden
/// kapanıyor — ekranda kalmak için bir sebep bırakmıyoruz.
struct BadgeMomentView: View {
    let entry: SketchEntry
    let badges: [SketchBadge]
    let onFinish: () -> Void

    @State private var stampVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var primaryBadge: SketchBadge? { badges.first }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack(alignment: .bottomTrailing) {
                    drawingImage
                    if let primaryBadge {
                        BadgeStamp(badge: primaryBadge, size: 104)
                            .background(
                                Circle().fill(Theme.background).padding(6)
                            )
                            .offset(x: 18, y: 18)
                            .scaleEffect(stampVisible ? 1 : (reduceMotion ? 1 : 1.6))
                            .opacity(stampVisible ? 1 : 0)
                    }
                }
                .padding(.horizontal, 32)

                if let primaryBadge {
                    VStack(spacing: 8) {
                        Text(primaryBadge.title)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                        Text(primaryBadge.caption)
                            .font(.body)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .opacity(stampVisible ? 1 : 0)
                }

                if badges.count > 1 {
                    HStack(spacing: 10) {
                        ForEach(badges.dropFirst()) { badge in
                            BadgeStamp(badge: badge, size: 46)
                        }
                    }
                    .opacity(stampVisible ? 1 : 0)
                }

                // Ödül anında bile konuyu hatırlatıyoruz: kazanılan şey
                // rozet değil, ekrandan uzakta geçen zaman.
                Label("\(entry.screenFreeMinutes) minutes away from the screen",
                      systemImage: "clock")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.primary.opacity(0.12)))
                    .opacity(stampVisible ? 1 : 0)

                Spacer()
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onFinish() }
        .task {
            withAnimation(reduceMotion ? .none : .spring(response: 0.45, dampingFraction: 0.6)) {
                stampVisible = true
            }
            try? await Task.sleep(for: .seconds(3.5))
            onFinish()
        }
    }

    @ViewBuilder
    private var drawingImage: some View {
        if let image = SketchPhotoStore.load(entry.photoFileName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusLarge)
                        .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Theme.cardShadow, radius: 16, y: 8)
        } else {
            RoundedRectangle(cornerRadius: Theme.radiusLarge)
                .fill(Theme.surface)
                .frame(height: 240)
        }
    }
}
