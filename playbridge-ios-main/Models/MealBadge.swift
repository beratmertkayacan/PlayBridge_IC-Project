//
//  MealBadge.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Meal Mode'un kazanımları.
///
/// Draw & Collect'teki mantığın küçük hâli: hiçbiri çocuğun CEVABINA
/// bakmıyor — cevabı değerlendiren bir uygulama, masadaki sohbeti
/// sınava çevirirdi. Rozetler yalnızca "kaç soru, hangi konudan"
/// bilgisinden hesaplanıyor.
enum MealBadge: String, Codable, CaseIterable, Identifiable, Hashable {
    case firstQuestion
    case tableSpotter
    case kitchenExplorer
    case tasteTester
    case dinnerStoryteller
    case allFourKinds
    case tenTogether

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstQuestion:     return "First Question"
        case .tableSpotter:      return "Table Spotter"
        case .kitchenExplorer:   return "Kitchen Explorer"
        case .tasteTester:       return "Taste Tester"
        case .dinnerStoryteller: return "Dinner Storyteller"
        case .allFourKinds:      return "All Four Kinds"
        case .tenTogether:       return "Ten Together"
        }
    }

    var caption: String {
        switch self {
        case .firstQuestion:     return "Your first question at the table."
        case .tableSpotter:      return "Three questions about what's on the table."
        case .kitchenExplorer:   return "Three questions about the kitchen."
        case .tasteTester:       return "Three questions about the food."
        case .dinnerStoryteller: return "Three stories told at the table."
        case .allFourKinds:      return "You've asked all four kinds."
        case .tenTogether:       return "Ten conversations, no screens."
        }
    }

    var systemImage: String {
        switch self {
        case .firstQuestion:     return "sparkles"
        case .tableSpotter:      return "square.grid.2x2.fill"
        case .kitchenExplorer:   return "refrigerator.fill"
        case .tasteTester:       return "carrot.fill"
        case .dinnerStoryteller: return "text.bubble.fill"
        case .allFourKinds:      return "circle.hexagongrid.fill"
        case .tenTogether:       return "fork.knife"
        }
    }

    static func categoryBadge(for category: MealPromptCategory) -> MealBadge {
        switch category {
        case .table:   return .tableSpotter
        case .kitchen: return .kitchenExplorer
        case .food:    return .tasteTester
        case .story:   return .dinnerStoryteller
        }
    }

    /// Bu kayıtla yeni kazanılan rozetler.
    static func newlyEarned(
        total: Int,
        countsByCategory: [MealPromptCategory: Int],
        alreadyEarned: Set<MealBadge>
    ) -> [MealBadge] {
        var earned: [MealBadge] = []

        if total >= 1  { earned.append(.firstQuestion) }
        if total >= 10 { earned.append(.tenTogether) }

        for category in MealPromptCategory.allCases where (countsByCategory[category] ?? 0) >= 3 {
            earned.append(MealBadge.categoryBadge(for: category))
        }

        if MealPromptCategory.allCases.allSatisfy({ (countsByCategory[$0] ?? 0) >= 1 }) {
            earned.append(.allFourKinds)
        }

        return earned.filter { !alreadyEarned.contains($0) }
    }
}
