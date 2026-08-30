//
//  SketchPhotoStore.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import UIKit

/// Çizim fotoğraflarının cihazdaki dosya deposu.
///
/// Fotoğraflar bilinçli olarak UserDefaults'a KOYULMUYOR. ProfileStore
/// ve PlayLibraryStore küçük kayıtlar için orayı kullanıyor ve bu
/// sorunsuz; ama UserDefaults her açılışta tamamen belleğe yükleniyor.
/// Oraya fotoğraf yazmak uygulamayı birkaç ay içinde şişirip açılışı
/// yavaşlatır. Bu yüzden görüntüler Documents/Sketches altında dosya
/// olarak duruyor, kayıt yalnızca dosya adını tutuyor.
///
/// Hiçbiri cihazdan çıkmıyor: yükleme yok, yedekleme servisi yok,
/// sunucuya giden hiçbir istek yok.
enum SketchPhotoStore {
    private static let folderName = "Sketches"

    /// Uzun kenar sınırı. Sıkıştırma olmadan bir yıllık defter yüz
    /// megabaytları bulur; bu sınırla çizim başına ~300 KB'de kalıyor.
    private static let maxDimension: CGFloat = 1600
    private static let jpegQuality: CGFloat = 0.8

    private static var folderURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(folderName, isDirectory: true)
    }

    private static func ensureFolder() {
        let url = folderURL
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    /// Görüntüyü küçültüp diske yazar, kayıtta tutulacak dosya adını döndürür.
    static func save(_ image: UIImage) -> String? {
        ensureFolder()
        let resized = downscaled(image)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else { return nil }

        let fileName = "\(UUID().uuidString).jpg"
        let url = folderURL.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            print("Çizim kaydedilemedi: \(error)")
            return nil
        }
    }

    static func load(_ fileName: String) -> UIImage? {
        UIImage(contentsOfFile: folderURL.appendingPathComponent(fileName).path)
    }

    static func delete(_ fileName: String) {
        try? FileManager.default.removeItem(at: folderURL.appendingPathComponent(fileName))
    }

    /// Defterin diskte kapladığı yer — ebeveyne gösterilebilsin diye.
    static func totalBytes() -> Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: folderURL, includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        return files.reduce(0) { sum, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return sum + Int64(size)
        }
    }

    private static func downscaled(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
