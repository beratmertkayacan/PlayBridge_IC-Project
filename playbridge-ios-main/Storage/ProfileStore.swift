//
//  ProfileStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum ProfileStore {
    private static let key = "playbridge.savedChildProfile"

    static func save(_ profile: ChildProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> ChildProfile? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let profile = try? JSONDecoder().decode(ChildProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
