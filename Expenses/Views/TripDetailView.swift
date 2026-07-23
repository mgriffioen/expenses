import SwiftUI
import SwiftData

struct TripDetailView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var isAddingExpense = false
    @State private var editingExpense: Expense?

    private var sortedExpenses: [Expense] {
        trip.expenses.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Total")
                    Spacer()
                    Text(trip.total, format: .currency(code: "USD")).bold()
                }
            }
            Section("Expenses") {
                ForEach(sortedExpenses) { expense in
                    Button {
                        editingExpense = expense
                    } label: {
                        ExpenseRowView(expense: expense)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteExpenses)
            }
        }
        .navigationTitle(trip.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingExpense) {
            ExpenseFormView(trip: trip)
        }
        .sheet(item: $editingExpense) { expense in
            ExpenseFormView(trip: trip, expenseToEdit: expense)
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        let expenses = sortedExpenses
        for index in offsets {
            let expense = expenses[index]
            if let filename = expense.receiptFilename {
                ReceiptImageStore.delete(filename)
            }
            context.delete(expense)
        }
    }
}
