//
//  ContentView.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var savedProfile: ChildProfile? = ProfileStore.load()

    var body: some View {
        if let profile = savedProfile {
            HomeDashboardView(childProfile: profile, onResetProfile: {
                ProfileStore.clear()
                savedProfile = nil
            })
        } else {
            OnboardingContainerView { profile in
                savedProfile = profile
            }
        }
    }
}
