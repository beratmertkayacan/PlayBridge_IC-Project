//
//  OnboardingViewModel.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

/// Onboarding'deki "What does your child enjoy?" kategorileri.
/// Tek ekranda 40 çip yığmak yorgun ebeveyni durdurur; kategori
/// seçilince o dünyanın seçenekleri açılır.
enum InterestCategory: String, CaseIterable, Identifiable {
    case worlds
    case making
    case moving
    case curious
    case everyday

    var id: String { rawValue }

    var title: String {
        switch self {
        case .worlds:   return "Worlds"
        case .making:   return "Making"
        case .moving:   return "Moving"
        case .curious:  return "Curious"
        case .everyday: return "Everyday"
        }
    }

    var options: [String] {
        switch self {
        case .worlds:
            return ["Dinosaurs", "Space", "Animals", "Ocean", "Superheroes", "Fairy tales", "Pokémon", "Minecraft", "Trains", "Robots"]
        case .making:
            return ["Drawing", "Building", "Crafts", "Music", "Cooking", "Lego", "Clay", "Fashion"]
        case .moving:
            return ["Cars", "Sports", "Dance", "Outdoor", "Bikes", "Swimming", "Martial arts"]
        case .curious:
            return ["Nature", "Science", "Inventions", "Puzzles", "How things work", "Coding", "Weather"]
        case .everyday:
            return ["Pretend play", "Family", "School", "Friendship", "Pets", "Board games", "Collecting"]
        }
    }
}

/// Onboarding'deki "What do you usually have nearby?" kategorileri.
/// Evdeki gerçek oyun malzemesini oda / mutfak / çizim diye ayırıyoruz;
/// ebeveyn "evde ne var"ı bir çırpıda tarayabilsin.
enum MaterialCategory: String, CaseIterable, Identifiable {
    case room
    case kitchen
    case drawing
    case playTogether
    case outdoor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .room:         return "Room"
        case .kitchen:      return "Kitchen"
        case .drawing:      return "Drawing"
        case .playTogether: return "Play together"
        case .outdoor:      return "Outdoor"
        }
    }

    var options: [String] {
        switch self {
        case .room:
            return ["Pillows", "Blankets", "Cushions", "Chairs", "Clothes", "Scarves", "Books", "Flashlight", "Laundry basket"]
        case .kitchen:
            return ["Spoons", "Bowls", "Cups", "Napkins", "Fruit", "Dry pasta", "Water", "Placemats", "Measuring cups"]
        case .drawing:
            return ["Paper", "Crayons", "Markers", "Colored pencils", "Stickers", "Tape", "Glue", "Cardboard", "Scissors"]
        case .playTogether:
            return ["Building blocks", "Lego", "Toy animals", "Dolls", "Cars", "Ball", "Board games", "Puppets", "Playing cards"]
        case .outdoor:
            return ["Sidewalk chalk", "Bucket", "Sticks", "Stones", "Jump rope", "Water", "Ball"]
        }
    }
}

@Observable
final class OnboardingViewModel {
    var selectedAgeRange: String? = nil
    var selectedInterests: Set<String> = []
    var selectedMaterials: Set<String> = []
    var isOnboardingComplete: Bool = false
    var completedProfile: ChildProfile? = nil

    var selectedInterestCategory: InterestCategory = .worlds
    private(set) var customInterests: [String] = []
    var manualInterestInput: String = ""

    var selectedMaterialCategory: MaterialCategory = .room
    private(set) var customMaterials: [String] = []
    var manualMaterialInput: String = ""

    // Yaş 12'ye kadar açık. Çizim oyunu ilkokul sonuna kadar taşıyor;
    // kademeler yukarı çıktıkça görevler kısıt içeren zorluklara dönüşüyor.
    let ageRanges = ["5-6", "7-8", "9-10", "11-12"]

    var presetInterestOptions: [String] {
        InterestCategory.allCases.flatMap(\.options)
    }

    var visibleInterestOptions: [String] {
        selectedInterestCategory.options
    }

    var sortedSelectedInterests: [String] {
        selectedInterests.sorted()
    }

    var presetMaterialOptions: [String] {
        MaterialCategory.allCases.flatMap(\.options)
    }

    var visibleMaterialOptions: [String] {
        selectedMaterialCategory.options
    }

    var sortedSelectedMaterials: [String] {
        selectedMaterials.sorted()
    }

    var canContinueFromAge: Bool { selectedAgeRange != nil }
    var canContinueFromInterests: Bool { !selectedInterests.isEmpty }
    var canContinueFromMaterials: Bool { !selectedMaterials.isEmpty }

    var canAddManualInterest: Bool {
        !manualInterestInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canAddManualMaterial: Bool {
        !manualMaterialInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
            customInterests.removeAll { $0 == interest }
        } else {
            selectedInterests.insert(interest)
        }
    }

    func addManualInterest() {
        let trimmed = manualInterestInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let alreadySelected = selectedInterests.contains {
            $0.caseInsensitiveCompare(trimmed) == .orderedSame
        }
        if !alreadySelected {
            selectedInterests.insert(trimmed)
            let isPreset = presetInterestOptions.contains {
                $0.caseInsensitiveCompare(trimmed) == .orderedSame
            }
            if !isPreset {
                customInterests.append(trimmed)
            }
        }
        manualInterestInput = ""
    }

    func removeCustomInterest(_ interest: String) {
        customInterests.removeAll { $0 == interest }
        selectedInterests.remove(interest)
    }

    func toggleMaterial(_ material: String) {
        if selectedMaterials.contains(material) {
            selectedMaterials.remove(material)
            customMaterials.removeAll { $0 == material }
        } else {
            selectedMaterials.insert(material)
        }
    }

    func addManualMaterial() {
        let trimmed = manualMaterialInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let alreadySelected = selectedMaterials.contains {
            $0.caseInsensitiveCompare(trimmed) == .orderedSame
        }
        if !alreadySelected {
            selectedMaterials.insert(trimmed)
            let isPreset = presetMaterialOptions.contains {
                $0.caseInsensitiveCompare(trimmed) == .orderedSame
            }
            if !isPreset {
                customMaterials.append(trimmed)
            }
        }
        manualMaterialInput = ""
    }

    func removeCustomMaterial(_ material: String) {
        customMaterials.removeAll { $0 == material }
        selectedMaterials.remove(material)
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
        // Oturum burada doğuyor: bu andan itibaren biriken süre ve
        // kazanımlar bu kimliğe bağlanıyor.
        SessionStore.start()
        completedProfile = profile
        isOnboardingComplete = true
    }
}
