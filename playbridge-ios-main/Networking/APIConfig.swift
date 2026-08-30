//
//  APIConfig.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

enum APIConfig {
    // Simülatörde çalışırken Mac'in localhost'una bu adresle erişilir.
    // Gerçek cihazda test ederken Mac'inizin yerel ağ IP'siyle değiştirin
    // (örn. "http://192.168.1.23:8000") — Simülatör için gerekmez.
    static let baseURL = URL(string: "http://127.0.0.1:8000")!
}
