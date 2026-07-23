import SwiftUI
import SwiftData

struct TripDetailView: View {
    let trip: Trip
    @Environment(\.modelContext) private var context
    @State private var isAddingExpense = false

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
                    ExpenseRowView(expense: expense)
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
            AddExpenseView(trip: trip)
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
