//
//  OnboardingViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

@Observable
final class OnboardingViewModel {
    var selectedAgeRange: String? = nil
    var selectedInterests: Set<String> = []
    var selectedMaterials: Set<String> = []
    var isOnboardingComplete: Bool = false
    var completedProfile: ChildProfile? = nil

    let ageRanges = ["3-4", "5-6", "7"]
    let interestOptions = ["Dinosaurs", "Space", "Animals", "Drawing", "Music", "Cars", "Building", "Nature", "Stories"]
    let materialOptions = ["Paper", "Crayons", "Building Blocks", "Toy Animals", "Books", "Pillows", "Ball"]

    var canContinueFromAge: Bool { selectedAgeRange != nil }
    var canContinueFromInterests: Bool { !selectedInterests.isEmpty }
    var canContinueFromMaterials: Bool { !selectedMaterials.isEmpty }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func toggleMaterial(_ material: String) {
        if selectedMaterials.contains(material) {
            selectedMaterials.remove(material)
        } else {
            selectedMaterials.insert(material)
        }
    }

    func completeOnboarding() {
        guard let ageRange = selectedAgeRange else { return }
        let profile = ChildProfile(
            ageRange: ageRange,
            interests: Array(selectedInterests),
            availableMaterials: Array(selectedMaterials),
            preferredActivityDuration: 15
        )
        ProfileStore.save(profile)
        completedProfile = profile
        isOnboardingComplete = true
    }
}
