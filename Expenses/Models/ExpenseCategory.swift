import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case food = "Food"
    case lodging = "Lodging"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case supplies = "Supplies"
    case other = "Other"

    var id: String { rawValue }
}
