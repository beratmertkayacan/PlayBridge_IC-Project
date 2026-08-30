//
//  MealModeViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

@MainActor
@Observable
final class MealModeViewModel {
    let childProfile: ChildProfile
    var prompt: String? = nil
    var isLoading: Bool = false

    init(childProfile: ChildProfile) {
        self.childProfile = childProfile
    }

    func fetchNewPrompt() {
        isLoading = true
        Task {
            let result = await MealService.fetchPrompt(ageRange: childProfile.ageRange)
            prompt = result
            isLoading = false
        }
    }
}
