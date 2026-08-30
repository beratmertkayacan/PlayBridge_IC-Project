//
//  PlayLibraryViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Kütüphanedeki filtre sekmeleri.
enum LibraryFilter: String, CaseIterable, Identifiable {
    case all
    case worked
    case notRated

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:      return "All"
        case .worked:   return "Worked"
        case .notRated: return "Not rated"
        }
    }
}

@MainActor
@Observable
final class PlayLibraryViewModel {
    private(set) var entries: [PlayedActivity] = []
    var filter: LibraryFilter = .all

    var visibleEntries: [PlayedActivity] {
        switch filter {
        case .all:
            return entries
        case .worked:
            return entries.filter { $0.feedback?.isPositive == true }
        case .notRated:
            return entries.filter { $0.feedback == nil }
        }
    }

    /// Kütüphanede hiç kayıt yok mu? (Boş ekranı bundan seçiyoruz.)
    var isEmpty: Bool { entries.isEmpty }

    /// Ebeveyne gösterilen küçük özet: "12 played · 7 worked".
    var summaryLine: String {
        let played = entries.count
        let worked = entries.filter { $0.feedback?.isPositive == true }.count
        let playLabel = played == 1 ? "1 activity played" : "\(played) activities played"
        return worked > 0 ? "\(playLabel) · \(worked) worked" : playLabel
    }

    func load() {
        entries = PlayLibraryStore.all()
    }

    func setFeedback(_ feedback: ActivityFeedback, for entry: PlayedActivity) {
        PlayLibraryStore.saveFeedback(feedback, for: entry.id)
        load()
    }

    func delete(_ entry: PlayedActivity) {
        PlayLibraryStore.delete(id: entry.id)
        load()
    }
}
