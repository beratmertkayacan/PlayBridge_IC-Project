//
//  SessionStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Bu cihazdaki oturumun kimliği.
///
/// Uygulamada giriş/kayıt YOK — kimlik doğrulama yapmıyoruz, e-posta,
/// parola, hesap istemiyoruz. "Oturum" burada yalnızca şu anlama geliyor:
/// onboarding'den itibaren biriken verinin bir arada tutulduğu dönem.
///
/// Kimlik onboarding tamamlandığında doğuyor, "oturumu sonlandır"
/// dendiğinde ölüyor ve yerine yenisi geliyor. Sunucudaki eski kayıtlar
/// SİLİNMİYOR — sadece artık başka bir oturuma ait oldukları için
/// toplamlara girmiyorlar. Böylece sayaçlar sıfırdan başlıyor ama
/// veri kaybı yaşanmıyor.
enum SessionStore {
    private static let key = "playbridge.sessionId"

    /// Mevcut oturum kimliği. Onboarding tamamlanmamışsa nil.
    static func current() -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    /// Yeni bir oturum başlatır ve kimliğini döner.
    @discardableResult
    static func start() -> String {
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
