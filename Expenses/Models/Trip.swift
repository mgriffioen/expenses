import Foundation
import SwiftData

@Model
final class Trip {
    var name: String
    var startDate: Date
    var endDate: Date?
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var expenses: [Expense] = []

    init(name: String, startDate: Date = .now, endDate: Date? = nil, notes: String = "") {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }

    var total: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
}
