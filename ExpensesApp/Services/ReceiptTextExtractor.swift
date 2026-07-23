import UIKit
import Vision

struct ExtractedReceiptData {
    var rawText: String
    var suggestedTotal: Decimal? = nil
    var suggestedMerchant: String? = nil
    var suggestedDate: Date? = nil
}

/// Runs on-device OCR over a receipt photo and makes a best-effort guess
/// at the merchant, total, and date. These are suggestions to pre-fill
/// the form — the user can always correct them before saving.
enum ReceiptTextExtractor {
    static func extract(from image: UIImage, completion: @escaping (ExtractedReceiptData) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ExtractedReceiptData(rawText: ""))
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            let rawText = lines.joined(separator: "\n")
            completion(
                ExtractedReceiptData(
                    rawText: rawText,
                    suggestedTotal: guessTotal(from: lines),
                    suggestedMerchant: lines.first,
                    suggestedDate: guessDate(from: lines)
                )
            )
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        }
    }

    private static func amounts(in line: String) -> [Decimal] {
        let regex = try! NSRegularExpression(pattern: #"\$?\s?(\d{1,5}(?:[.,]\d{2}))"#)
        let range = NSRange(line.startIndex..., in: line)
        return regex.matches(in: line, range: range).compactMap { match in
            guard let r = Range(match.range(at: 1), in: line) else { return nil }
            return Decimal(string: line[r].replacingOccurrences(of: ",", with: "."))
        }
    }

    private static func guessTotal(from lines: [String]) -> Decimal? {
        let totalKeywords = ["total", "amount due", "balance due"]
        for line in lines where totalKeywords.contains(where: { line.lowercased().contains($0) }) {
            if let amount = amounts(in: line).last {
                return amount
            }
        }
        return lines.flatMap(amounts).max()
    }

    private static func guessDate(from lines: [String]) -> Date? {
        let formats = ["MM/dd/yyyy", "M/d/yy", "MM-dd-yyyy", "yyyy-MM-dd"]
        let formatters: [DateFormatter] = formats.map {
            let formatter = DateFormatter()
            formatter.dateFormat = $0
            return formatter
        }
        let regex = try! NSRegularExpression(pattern: #"\d{1,4}[/-]\d{1,2}[/-]\d{2,4}"#)

        for line in lines {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range),
                  let r = Range(match.range, in: line) else { continue }
            let candidate = String(line[r])
            for formatter in formatters {
                if let date = formatter.date(from: candidate) {
                    return date
                }
            }
        }
        return nil
    }
}
