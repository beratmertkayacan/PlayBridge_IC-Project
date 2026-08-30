//
//  AppReset.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Oturumu sonlandırma.
///
/// Uygulamada giriş yok; "oturum" onboarding'den itibaren biriken
/// verinin bütünü demek. Sonlandırıldığında cihazda hiçbir iz kalmıyor:
/// profil, oynanan aktiviteler, geri bildirimler, çizimler ve
/// fotoğrafları, rozetler, haftalık ilerleme, yemek soruları — hepsi.
///
/// Tek bir yerde toplanmasının sebebi: ileride yeni bir depo eklendiğinde
/// buraya bir satır eklemek unutulursa, kullanıcıya verdiğimiz "her şey
/// silinir" sözü sessizce yalan olur. Silme mantığı dağıtılmamalı.
enum AppReset {

    /// Her şeyi siler ve uygulamayı onboarding'in başına döndürür.
    ///
    /// Sunucudaki geçmiş kayıtlara DOKUNMUYOR — yeni oturum kimliği
    /// üretildiği için o kayıtlar artık toplamlara girmiyor. Bu, veri
    /// kaybetmeden sayacı sıfırlamanın en temiz yolu.
    static func endSession() {
        ProfileStore.clear()
        PlayLibraryStore.clear()
        SketchStore.clearAll()
        ActiveChallengeStore.clear()
        MealStore.clear()
        SessionStore.clear()
    }
}
