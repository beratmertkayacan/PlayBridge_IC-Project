//
//  PlayBridgeAIApp.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import SwiftUI

@main
struct PlayBridgeAIApp: App {
    init() {
        // Bu açılışın zamanını sabitliyoruz — geri bildirim sorusu
        // "sonraki açılışta" sorulacak, bunun için gerekiyor.
        AppSession.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
