import UIKit

/// Saves receipt photos as JPEG files in the app's Documents directory,
/// keyed by filename. Expense records store just the filename, not the image data,
/// to keep the SwiftData store small.
enum ReceiptImageStore {
    private static var receiptsDirectory: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Receipts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let url = receiptsDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Failed to save receipt image: \(error)")
            return nil
        }
    }

    static func load(_ filename: String) -> UIImage? {
        let url = receiptsDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(_ filename: String) {
        let url = receiptsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
