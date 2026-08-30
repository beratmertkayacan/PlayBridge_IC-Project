//
//  AppSession.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Bu uygulama açılışının başlangıç zamanı.
///
/// Tek işi var: "geri bildirimi sonraki açılışta sor" kuralını mümkün
/// kılmak. Ebeveyn oyunu işaretledikten HEMEN sonra "nasıl gitti?" diye
/// sormak anlamsız — oyun henüz oynanmadı. Bu yüzden ana ekran sadece
/// `launchedAt`'ten ÖNCE oynanmış kayıtlar için soru soruyor.
enum AppSession {
    static let launchedAt = Date()

    /// Uygulama açılışında bir kez çağrılıyor ki `launchedAt` gerçekten
    /// açılış anını yakalasın (static let tembel yüklenir).
    static func start() {
        _ = launchedAt
    }
}
