//
//  ScreenToPlayViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

@MainActor
@Observable
final class ScreenToPlayViewModel {
    let childProfile: ChildProfile
    var screenTopic: String = ""
    var isGenerating: Bool = false
    var generatedResult: GeneratedActivityResponse? = nil

    /// Sonucu üreten konu — "Try a different idea" için gerekiyor.
    private(set) var lastTopic: String? = nil

    var canGenerate: Bool {
        !screenTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(childProfile: ChildProfile) {
        self.childProfile = childProfile
    }

    func generate() {
        guard canGenerate else { return }
        let topic = screenTopic
        lastTopic = topic
        isGenerating = true
        Task {
            let response = await ScreenToPlayService.generateActivity(
                ageRange: childProfile.ageRange,
                screenTopic: topic
            )
            generatedResult = response
            isGenerating = false
        }
    }
}
