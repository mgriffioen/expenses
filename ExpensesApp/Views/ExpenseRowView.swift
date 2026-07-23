import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack {
            if let filename = expense.receiptFilename, let image = ReceiptImageStore.load(filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.quaternary)
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "receipt"))
            }
            VStack(alignment: .leading) {
                Text(expense.merchant).font(.body)
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount, format: .currency(code: "USD"))
        }
    }
}
