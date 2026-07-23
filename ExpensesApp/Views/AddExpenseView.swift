import SwiftUI

struct AddExpenseView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var merchant = ""
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var category = ExpenseCategory.other
    @State private var notes = ""
    @State private var receiptImage: UIImage?

    @State private var isScanning = false
    @State private var isExtracting = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        isScanning = true
                    } label: {
                        Label(
                            receiptImage == nil ? "Scan Receipt" : "Rescan Receipt",
                            systemImage: "camera.viewfinder"
                        )
                    }
                    if let receiptImage {
                        Image(uiImage: receiptImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    if isExtracting {
                        ProgressView("Reading receipt…")
                    }
                }
                Section {
                    TextField("Merchant", text: $merchant)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(merchant.isEmpty || Decimal(string: amountText) == nil)
                }
            }
            .fullScreenCover(isPresented: $isScanning) {
                ReceiptScannerView(
                    onScan: handleScan,
                    onCancel: { isScanning = false }
                )
                .ignoresSafeArea()
            }
        }
    }

    private func handleScan(_ image: UIImage) {
        isScanning = false
        receiptImage = image
        isExtracting = true
        ReceiptTextExtractor.extract(from: image) { extracted in
            DispatchQueue.main.async {
                isExtracting = false
                if let total = extracted.suggestedTotal {
                    amountText = "\(total)"
                }
                if let name = extracted.suggestedMerchant, merchant.isEmpty {
                    merchant = name
                }
                if let extractedDate = extracted.suggestedDate {
                    date = extractedDate
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        let receiptFilename = receiptImage.flatMap { ReceiptImageStore.save($0) }
        let expense = Expense(
            merchant: merchant,
            amount: amount,
            date: date,
            category: category,
            notes: notes,
            receiptFilename: receiptFilename,
            trip: trip
        )
        context.insert(expense)
        dismiss()
    }
}
