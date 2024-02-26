//
//  FinancialOperationEntryView.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import SwiftUI

struct FinancialOperationEntryView: View {
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Amount", value: $amount, format: .currency(code: "USD"))
                .textFieldStyle(.roundedBorder)
            Button("Save") {
                isPresented = false
                print("Saved operation: \(name) - \(amount)")
                saveOperation()
            }
            .disabled(name.isEmpty || amount == 0.0)
        }
        .padding()
    }

    private func saveOperation() {
        let newOperation = Item(context: managedObjectContext)
        newOperation.name = name
        newOperation.amount = NSDecimalNumber(value: amount)
        newOperation.timestamp = Date()

        do {
          try managedObjectContext.save()
        } catch {
          print("Error saving operation: \(error.localizedDescription)")
        }
    }
}


#Preview {
    FinancialOperationEntryView(isPresented: .constant(true))
}
