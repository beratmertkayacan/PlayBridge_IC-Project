//
//  ActivityRequest.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 29.08.2026.
//

import Foundation

struct ActivityRequest: Codable, Hashable {
    var ageRange: String
    var interests: [String]
    /// Hazır çiplerden seçilenler + ebeveynin elle yazdıkları, tek liste
    /// hâlinde. Backend "sadece bu malzemeleri kullan" diyor, o yüzden
    /// ikisini ayırmanın modele bir faydası yok.
    var availableMaterials: [String]
    var durationMinutes: Int
    var parentSetupMinutes: Int
    var mode: String   // "independent", "together", "meal", "screen_to_play"

    /// Ebeveynin şu an bulunduğu ortam: "Living room", "In the kitchen",
    /// "In the car", "Outdoor". Seçilmesi zorunlu değil — bu yüzden Optional.
    ///
    /// Optional olması ayrıca ESKİ kayıtları da kurtarıyor: kütüphanede
    /// bu alan eklenmeden önce kaydedilmiş oyunlar var; Swift eksik bir
    /// anahtarı Optional alanda nil olarak çözüyor, yani eski kayıtlar
    /// bozulmadan okunmaya devam ediyor.
    var location: String?
}
