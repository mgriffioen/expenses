import SwiftUI
import SwiftData

struct ExpenseRowView: View {
    let expense: Expense
    @State private var isShowingReceipt = false

    var body: some View {
        let receiptImage = expense.receiptFilename.flatMap { ReceiptImageStore.load($0) }

        HStack {
            if let receiptImage {
                Button {
                    isShowingReceipt = true
                } label: {
                    Image(uiImage: receiptImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
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
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $isShowingReceipt) {
            if let receiptImage {
                ReceiptFullScreenView(image: receiptImage)
            }
        }
    }
}
