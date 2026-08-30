//
//  ScreenTimeViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

@MainActor
@Observable
final class ScreenTimeViewModel {
    var savedMinutesThisWeek: Int = 0
    var isLoading: Bool = false

    var headline: String {
        if savedMinutesThisWeek == 0 {
            return "0"
        }
        return "\(savedMinutesThisWeek)"
    }

    var unitLabel: String {
        savedMinutesThisWeek == 1 ? "minute" : "minutes"
    }

    var caption: String {
        if savedMinutesThisWeek == 0 {
            return "Complete a play activity and the time shows up here."
        }
        return "screen time saved this week"
    }

    func refresh() {
        isLoading = true
        Task {
            let remote = await ScreenTimeService.fetchMinutesThisWeek()
            let local = PlayLibraryStore.minutesSavedThisWeek()
            savedMinutesThisWeek = max(remote, local)
            isLoading = false
        }
    }
}
