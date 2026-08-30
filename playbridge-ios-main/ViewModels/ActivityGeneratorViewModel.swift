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
    var manualDurationInput: String = ""
    var manualSetupInput: String = ""

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

    /// Profilde kayıtlı malzemeler üstte dursun, ardından sık kullanılan
    /// ekstra çipler gelsin. Onboarding'de seçilen "Dry pasta" gibi
    /// şeyler kaybolmasın.
    var visibleMaterialChips: [String] {
        let selected = Array(selectedMaterials).sorted()
        let extras = MaterialsSection.defaultOptions.filter { option in
            !selectedMaterials.contains { $0.caseInsensitiveCompare(option) == .orderedSame }
                && !customMaterials.contains { $0.caseInsensitiveCompare(option) == .orderedSame }
        }
        return selected + extras
    }

    /// Backend'e gidecek nihai malzeme listesi: seçilenler + elle yazılanlar.
    var allMaterials: [String] {
        Array(selectedMaterials) + customMaterials
    }

    /// Together + In the car: elde hiçbir şey olmasa da üretim açılır.
    /// Camdan bakma / sayma / tahmin oyunu üretilir.
    var allowsEmptyMaterials: Bool {
        mode == "together" && selectedLocation == "In the car"
    }

    var nothingInHand: Bool {
        allowsEmptyMaterials && allMaterials.isEmpty
    }

    var canGenerate: Bool {
        guard selectedDuration != nil && selectedSetupTime != nil else { return false }
        if allowsEmptyMaterials { return true }
        return !allMaterials.isEmpty
    }

    /// TextField'daki metin eklenebilir durumda mı? (Boşluk yazıp
    /// "+" ya basmanın bir anlamı yok.)
    var canAddManualMaterial: Bool {
        !manualMaterialInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canAddManualDuration: Bool {
        parsedMinutes(manualDurationInput, minimum: 1, maximum: 180) != nil
    }

    var canAddManualSetup: Bool {
        parsedMinutes(manualSetupInput, minimum: 0, maximum: 60) != nil
    }

    /// Çip listesinde olmayan, elle girilmiş süre.
    var extraDurationChip: Int? {
        guard let value = selectedDuration, !durationOptions.contains(value) else { return nil }
        return value
    }

    var extraSetupChip: Int? {
        guard let value = selectedSetupTime, !setupTimeOptions.contains(value) else { return nil }
        return value
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

    func clearMaterials() {
        selectedMaterials.removeAll()
        customMaterials.removeAll()
    }

    func selectDuration(_ minutes: Int) {
        selectedDuration = minutes
        manualDurationInput = ""
    }

    func addManualDuration() {
        guard let minutes = parsedMinutes(manualDurationInput, minimum: 1, maximum: 180) else { return }
        selectedDuration = minutes
        manualDurationInput = ""
    }

    func selectSetupTime(_ minutes: Int) {
        selectedSetupTime = minutes
        manualSetupInput = ""
    }

    func addManualSetup() {
        guard let minutes = parsedMinutes(manualSetupInput, minimum: 0, maximum: 60) else { return }
        selectedSetupTime = minutes
        manualSetupInput = ""
    }

    func selectLocation(_ location: String?) {
        selectedLocation = location
        if mode == "together" && location == "In the car" {
            clearMaterials()
        }
    }

    func toggleLocation(_ location: String) {
        if selectedLocation == location {
            selectLocation(nil)
        } else {
            selectLocation(location)
        }
    }

    private func parsedMinutes(_ raw: String, minimum: Int, maximum: Int) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(trimmed), value >= minimum, value <= maximum else { return nil }
        return value
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
