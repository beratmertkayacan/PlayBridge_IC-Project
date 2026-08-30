//
//  ActivityGeneratorViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

@MainActor
@Observable
final class ActivityGeneratorViewModel {
    let childProfile: ChildProfile
    let mode: String

    var selectedDuration: Int?
    var selectedSetupTime: Int?
    var selectedMaterials: Set<String>

    var isGenerating: Bool = false
    var generatedResult: GeneratedActivityResponse? = nil

    /// Sonucu ÜRETEN istek. Sonuç ekranındaki "Try a different idea"
    /// butonu aynı istekle yeniden üretim yapabilsin diye saklıyoruz.
    private(set) var lastRequest: ActivityRequest? = nil

    let durationOptions = [5, 10, 15, 20, 30]
    let setupTimeOptions = [0, 2, 5, 10]

    var canGenerate: Bool {
        selectedDuration != nil && selectedSetupTime != nil && !selectedMaterials.isEmpty
    }

    init(childProfile: ChildProfile, mode: String = "independent") {
        self.childProfile = childProfile
        self.mode = mode
        self.selectedMaterials = Set(childProfile.availableMaterials)
        self.selectedDuration = childProfile.preferredActivityDuration
    }

    func toggleMaterial(_ material: String) {
        if selectedMaterials.contains(material) {
            selectedMaterials.remove(material)
        } else {
            selectedMaterials.insert(material)
        }
    }

    func buildRequest() -> ActivityRequest? {
        guard let duration = selectedDuration, let setupTime = selectedSetupTime else { return nil }
        return ActivityRequest(
            ageRange: childProfile.ageRange,
            interests: childProfile.interests,
            availableMaterials: Array(selectedMaterials),
            durationMinutes: duration,
            parentSetupMinutes: setupTime,
            mode: mode
        )
    }

    func generateActivity() {
        guard let request = buildRequest() else { return }
        lastRequest = request
        isGenerating = true
        Task {
            let response = await ActivityService.generateActivity(for: request)
            generatedResult = response
            isGenerating = false
        }
    }
}
