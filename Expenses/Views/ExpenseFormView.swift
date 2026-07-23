import SwiftUI
import SwiftData

/// Handles both creating a new expense and editing an existing one,
/// depending on whether `expenseToEdit` is provided.
struct ExpenseFormView: View {
    let trip: Trip
    var expenseToEdit: Expense?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var merchant = ""
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var category = ExpenseCategory.other
    @State private var notes = ""
    @State private var receiptImage: UIImage?
    @State private var existingReceiptFilename: String?
    @State private var didChangeReceipt = false

    @State private var isScanning = false
    @State private var isExtracting = false
    @State private var showDeleteConfirmation = false

    private var isEditing: Bool { expenseToEdit != nil }

    init(trip: Trip, expenseToEdit: Expense? = nil) {
        self.trip = trip
        self.expenseToEdit = expenseToEdit
        if let expense = expenseToEdit {
            _merchant = State(initialValue: expense.merchant)
            _amountText = State(initialValue: "\(expense.amount)")
            _date = State(initialValue: expense.date)
            _category = State(initialValue: expense.category)
            _notes = State(initialValue: expense.notes)
            _existingReceiptFilename = State(initialValue: expense.receiptFilename)
            if let filename = expense.receiptFilename {
                _receiptImage = State(initialValue: ReceiptImageStore.load(filename))
            }
        }
    }

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
                if isEditing {
                    Section {
                        Button("Delete Expense", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "New Expense")
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
            .confirmationDialog(
                "Delete this expense?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteExpense() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func handleScan(_ image: UIImage) {
        isScanning = false
        receiptImage = image
        didChangeReceipt = true
        isExtracting = true
        ReceiptTextExtractor.extract(from: image) { extracted in
            DispatchQueue.main.async {
                isExtracting = false
                if let total = extracted.suggestedTotal {
                    amountText = "\(total)"
                }
                if let name = extracted.suggestedMerchant {
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

        var receiptFilename = existingReceiptFilename
        if didChangeReceipt {
            if let existingReceiptFilename {
                ReceiptImageStore.delete(existingReceiptFilename)
            }
            receiptFilename = receiptImage.flatMap { ReceiptImageStore.save($0) }
        }

        if let expense = expenseToEdit {
            expense.merchant = merchant
            expense.amount = amount
            expense.date = date
            expense.category = category
            expense.notes = notes
            expense.receiptFilename = receiptFilename
        } else {
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
        }
        dismiss()
    }

    private func deleteExpense() {
        guard let expense = expenseToEdit else { return }
        if let filename = expense.receiptFilename {
            ReceiptImageStore.delete(filename)
        }
        context.delete(expense)
        dismiss()
    }
}
