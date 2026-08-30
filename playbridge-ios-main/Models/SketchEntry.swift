//
//  SketchEntry.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Deftere kaydedilmiş bir çizim.
///
/// Fotoğrafın kendisi BURADA DEĞİL: kayıt yalnızca dosya adını tutuyor,
/// görüntü uygulamanın Documents klasöründe duruyor. Sebebi basit —
/// bu kayıtlar UserDefaults'a yazılıyor ve oraya fotoğraf koymak
/// uygulamayı birkaç ay içinde şişirip açılışta yavaşlatır.
struct SketchEntry: Codable, Identifiable, Hashable {
    var id: String
    var challengeText: String
    var category: SketchCategory
    var tier: AgeTier
    var photoFileName: String
    var createdAt: Date
    var points: Int

    /// Görev ekranının açıldığı andan fotoğrafın kaydedildiği ana kadar
    /// geçen GERÇEK süre (dakika). Uydurulmuş bir tahmin değil, ölçülen
    /// bir değer — "ekrandan uzakta geçen zaman" toplamı bundan çıkıyor.
    var screenFreeMinutes: Int

    init(
        challenge: DrawingChallenge,
        photoFileName: String,
        screenFreeMinutes: Int,
        createdAt: Date = Date(),
        points: Int = SketchEntry.pointsPerSketch
    ) {
        self.id = UUID().uuidString
        self.challengeText = challenge.text
        self.category = challenge.category
        self.tier = challenge.tier
        self.photoFileName = photoFileName
        self.screenFreeMinutes = screenFreeMinutes
        self.createdAt = createdAt
        self.points = points
    }

    /// Her çizim eşit puan. Sabit, koşulsuz, tartışmasız.
    ///
    /// Kalite değerlendirilmiyor: bir çocuğun çizimine düşük puan veren
    /// uygulama, o çocuğu ve ebeveynini aynı anda kaybeder.
    static let pointsPerSketch = 10
}
