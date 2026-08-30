//
//  SketchbookView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import SwiftUI

/// Çizim defteri — Play Library'nin "Sketchbook" sekmesinin içeriği.
///
/// Kendi ScrollView'u YOK: kütüphanenin mevcut kaydırma alanının içine
/// yerleşiyor. İç içe iki kaydırma alanı hem yanlış davranır hem de
/// üstteki "bu hafta kurtarılan süre" kartını sekmeden ayırırdı.
///
/// Bu ekran özelliğin bütün amacı: bir yıl sonra ebeveynin uygulamayı
/// silmemesinin sebebi burada birikiyor.
struct SketchbookContent: View {
    @State private var entries: [SketchEntry] = []
    @State private var earnedBadges: Set<SketchBadge> = []
    @State private var selected: SketchEntry?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    summary
                    badgeShelf
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(entries) { entry in
                            Button { selected = entry } label: { tile(entry) }
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .onAppear(perform: reload)
        .sheet(item: $selected) { entry in
            SketchDetailView(entry: entry) {
                SketchStore.delete(entry)
                selected = nil
                reload()
            }
        }
    }

    private func reload() {
        entries = SketchStore.allEntries()
        earnedBadges = SketchStore.earnedBadges()
    }

    /// Üstteki kart BU HAFTA kurtarılan süreyi gösteriyor (backend'den).
    /// Buradaki satır ise defterin kendi TÜM ZAMANLAR toplamı — ikisi
    /// farklı sorulara cevap veriyor, o yüzden ikisi de duruyor.
    private var summary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(allTimeHeadline)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text("\(entries.count) \(entries.count == 1 ? "drawing" : "drawings") · \(earnedBadges.count) \(earnedBadges.count == 1 ? "badge" : "badges") · \(SketchStore.totalPoints) points")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var allTimeHeadline: String {
        let minutes = SketchStore.totalScreenFreeMinutes
        if minutes < 60 { return "\(minutes) minutes of drawing, all time" }
        let hours = minutes / 60
        let rest = minutes % 60
        let hourPart = "\(hours) \(hours == 1 ? "hour" : "hours")"
        return rest == 0
            ? "\(hourPart) of drawing, all time"
            : "\(hourPart) \(rest) min of drawing, all time"
    }

    private var badgeShelf: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BADGES")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Kazanılmamış rozetler de görünüyor ama soluk:
                    // koleksiyonun devamı olduğunu göstermek, boşluğu
                    // gizlemekten daha iyi bir motivasyon.
                    ForEach(SketchBadge.allCases) { badge in
                        VStack(spacing: 6) {
                            BadgeStamp(badge: badge, size: 58, isEarned: earnedBadges.contains(badge))
                            Text(badge.title)
                                .font(.caption2)
                                .foregroundStyle(earnedBadges.contains(badge) ? Theme.textPrimary : Theme.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(width: 78)
                        .opacity(earnedBadges.contains(badge) ? 1 : 0.45)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func tile(_ entry: SketchEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = SketchPhotoStore.load(entry.photoFileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 132)
                    .clipped()
            } else {
                Rectangle().fill(Theme.surface).frame(height: 132)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.challengeText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(shortDate(entry.createdAt))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(RoundedRectangle(cornerRadius: Theme.radiusMedium).fill(Color.white))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMedium)
                .strokeBorder(Theme.textSecondary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Theme.cardShadow, radius: 8, y: 4)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.primary.opacity(0.12)).frame(width: 76, height: 76)
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.primary)
            }
            Text("The sketchbook is empty")
                .font(.title3.bold())
                .foregroundStyle(Theme.textPrimary)
            Text("Take a drawing challenge from the home screen. Every drawing you add stays on this phone — and stays here for good.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 36)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
