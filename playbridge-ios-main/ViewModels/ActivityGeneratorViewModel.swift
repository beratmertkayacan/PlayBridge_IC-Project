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

    /// Hazır listeden seçilen malzemeler.
    var selectedMaterials: Set<String>

    /// Ebeveynin elle yazdığı, hazır listede olmayan malzemeler.
    /// Set değil dizi: ebeveynin yazdığı sıra korunsun istiyoruz.
    private(set) var customMaterials: [String] = []

    /// TextField'a bağlı geçici metin. Eklendikten sonra temizleniyor.
    var manualMaterialInput: String = ""

    /// Ebeveynin şu an bulunduğu ortam. Seçmek zorunlu değil.
    var selectedLocation: String?

    var isGenerating: Bool = false
    var generatedResult: GeneratedActivityResponse? = nil

    /// Sonucu ÜRETEN istek. Sonuç ekranındaki "Suggest another one"
    /// butonu aynı istekle yeniden üretim yapabilsin diye saklıyoruz.
    private(set) var lastRequest: ActivityRequest? = nil

    let durationOptions = [5, 10, 15, 20, 30]
    let setupTimeOptions = [0, 2, 5, 10]

    /// Mekan seçenekleri. ViewModel'de duruyorlar çünkü iki giriş ekranı
    /// da aynı listeyi kullanıyor — tek yerde durunca ikisi ayrışmıyor.
    let locationOptions = ["Living room", "In the kitchen", "In the car", "Outdoor"]

    /// Backend'e gidecek nihai malzeme listesi: seçilenler + elle yazılanlar.
    var allMaterials: [String] {
        Array(selectedMaterials) + customMaterials
    }

    var canGenerate: Bool {
        selectedDuration != nil && selectedSetupTime != nil && !allMaterials.isEmpty
    }

    /// TextField'daki metin eklenebilir durumda mı? (Boşluk yazıp
    /// "+" ya basmanın bir anlamı yok.)
    var canAddManualMaterial: Bool {
        !manualMaterialInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

    /// Elle yazılan malzemeyi listeye ekler.
    ///
    /// İki şeyi engelliyoruz: boş girdi ve aynı şeyin iki kez eklenmesi.
    /// Karşılaştırma büyük/küçük harf duyarsız — ebeveyn "Lego" yazdıysa
    /// ve listede "lego" varsa bu ikisi aynı şeydir.
    func addManualMaterial() {
        let trimmed = manualMaterialInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let alreadyExists = allMaterials.contains {
            $0.caseInsensitiveCompare(trimmed) == .orderedSame
        }
        if !alreadyExists {
            customMaterials.append(trimmed)
        }
        manualMaterialInput = ""
    }

    func removeCustomMaterial(_ material: String) {
        customMaterials.removeAll { $0 == material }
    }

    /// Mekan çipine tekrar dokunulursa seçim kalkıyor — ebeveyn yanlış
    /// seçtiyse fikrini geri alabilmeli.
    func toggleLocation(_ location: String) {
        selectedLocation = (selectedLocation == location) ? nil : location
    }

    func buildRequest() -> ActivityRequest? {
        guard let duration = selectedDuration, let setupTime = selectedSetupTime else { return nil }
        return ActivityRequest(
            ageRange: childProfile.ageRange,
            interests: childProfile.interests,
            availableMaterials: allMaterials,
            durationMinutes: duration,
            parentSetupMinutes: setupTime,
            mode: mode,
            location: selectedLocation
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
