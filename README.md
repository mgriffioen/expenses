# Expenses

An iPhone app for tracking expenses grouped by trip/event, with receipt
scanning and on-device text extraction.

- **UI:** SwiftUI
- **Storage:** SwiftData, local to the device (no backend, no account)
- **Receipt capture:** VisionKit's `VNDocumentCameraViewController` (auto
  crop/perspective-correct)
- **Receipt OCR:** Vision's `VNRecognizeTextRequest`, fully on-device — no
  cloud API, no network calls, receipts never leave the phone

## What's in this repo

A working Xcode project under `Expenses/`:

```
Expenses/
  Expenses.xcodeproj/
  Expenses-Info.plist
  ExpensesApp.swift        # app entry point
  Models/
    Trip.swift              # a trip/event; owns a list of expenses
    Expense.swift            # a single expense, optionally with a receipt photo
    ExpenseCategory.swift
  Services/
    ReceiptImageStore.swift  # saves/loads receipt photos to disk
    ReceiptScannerView.swift # wraps the VisionKit document camera
    ReceiptTextExtractor.swift # OCR + heuristics to guess total/merchant/date
  Views/
    TripListView.swift
    AddTripView.swift
    TripDetailView.swift
    ExpenseRowView.swift
    AddExpenseView.swift     # manual entry + "Scan Receipt" flow
  ExpensesTests/
  ExpensesUITests/
```

## Running it

1. Clone the repo and open `Expenses/Expenses.xcodeproj` in Xcode.
2. Pick a run destination (Simulator or your iPhone) and press Cmd+R.
   - The Simulator has no camera, so receipt scanning needs a real device —
     everything else (add trip, add expense manually) works in the
     Simulator.
3. **To run on your iPhone:**
   - Plug your iPhone into your Mac.
   - In Xcode → Settings → Accounts, sign in with your Apple ID (free is
     fine).
   - Select the project → target → **Signing & Capabilities** → set your
     Team to your personal team.
   - Select your iPhone as the run destination and press Cmd+R.
   - First run: on the iPhone, go to Settings → General → VPN & Device
     Management (naming may vary by iOS version) and trust your developer
     certificate.
   - Apps signed with a free Apple ID need re-signing (just re-run from
     Xcode) about once a week.

## Current feature set

- Create trips/events, each with its own running total
- Add expenses manually (merchant, amount, date, category, notes)
- Scan a receipt with the camera; the photo is saved and OCR pre-fills
  the amount, merchant, and date (best-effort — always editable before
  saving)
- Delete trips/expenses (removes the associated receipt image from disk)

## Natural next steps

- Edit an existing expense (currently only add/delete)
- Filter/search expenses across trips, or by category
- Export a trip's expenses (e.g. CSV or PDF) for reimbursement
- iCloud sync via SwiftData + CloudKit, if you want the same data across
  multiple devices
- Tap a receipt thumbnail to view the full-size photo
