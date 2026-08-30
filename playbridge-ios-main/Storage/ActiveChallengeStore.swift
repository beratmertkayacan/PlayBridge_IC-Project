//
//  ActiveChallengeStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Başlatılmış ama henüz fotoğrafı kaydedilmemiş görev.
struct ActiveChallenge: Codable, Hashable {
    var challenge: DrawingChallenge
    var startedAt: Date

    /// Görev başlatıldığından bu yana geçen dakika, makul bir aralığa
    /// sıkıştırılmış hâlde.
    ///
    /// Neden sınır var: ebeveyn görevi başlatıp telefonu bırakabilir ve
    /// üç saat sonra dönebilir. O üç saatin tamamını "ekransız oyun"
    /// diye saymak sayıyı şişirir ve yalan söyler. En az 1, en fazla 45.
    var elapsedMinutes: Int {
        let minutes = Int(Date().timeIntervalSince(startedAt) / 60)
        return min(max(minutes, 1), 45)
    }
}

/// Aktif görevin diskteki kaydı.
///
/// Bunun kalıcı olması özelliğin en kritik teknik detayı: uygulamanın
/// asıl istediği şey ebeveynin telefonu BIRAKMASI. Görev yalnızca
/// bellekte tutulsaydı, uygulama kapatıldığı anda görev ve süre ölçümü
/// kaybolurdu — yani ürün, kendi vaadini yerine getiren kullanıcıyı
/// cezalandırırdı.
enum ActiveChallengeStore {
    private static let key = "playbridge.activeChallenge"

    static func load() -> ActiveChallenge? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let active = try? JSONDecoder().decode(ActiveChallenge.self, from: data) else {
            return nil
        }
        return active
    }

    static func start(_ challenge: DrawingChallenge) {
        let active = ActiveChallenge(challenge: challenge, startedAt: Date())
        if let data = try? JSONEncoder().encode(active) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
