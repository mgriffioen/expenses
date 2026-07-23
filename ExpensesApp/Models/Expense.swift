import Foundation
import SwiftData

@Model
final class Expense {
    var merchant: String
    var amount: Decimal
    var date: Date
    var categoryRaw: String
    var notes: String
    var receiptFilename: String?
    var trip: Trip?

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        merchant: String,
        amount: Decimal,
        date: Date = .now,
        category: ExpenseCategory = .other,
        notes: String = "",
        receiptFilename: String? = nil,
        trip: Trip? = nil
    ) {
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.categoryRaw = category.rawValue
        self.notes = notes
        self.receiptFilename = receiptFilename
        self.trip = trip
    }
}
