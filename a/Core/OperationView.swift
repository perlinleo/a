//
//  OperationView.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import SwiftUI

struct OperationView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var onDelete = {}
    var item: Date
    var amount: Decimal
    var name: String

    var isLoss: Bool {
        return amount < 0
    }

    func onDelete(_ callback: @escaping () -> Void) -> some View {
        OperationView(onDelete: callback, item: self.item, amount: self.amount, name: self.name)
    }

    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                HStack {
                    VStack(alignment: .leading, content: {
                        Text("\(name)")
                            .font(.headline)
                        Text("\(name) at \(item, formatter: itemFormatter)")
                            .font(.subheadline)
                    })
                    Spacer()
                    Text("\(amount, format: .currency(code: "USD"))")
                        .foregroundStyle(isLoss ? .red : .green)
                        .font(.title3)
                }
                .frame(width: UIScreen.main.bounds.width - 48)
                .padding(.init(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .padding(.init(top: .zero, leading: 12, bottom: .zero, trailing: 12))
                Button(action: {
                    self.onDelete()
                }, label: {
                    Image(systemName: "minus.circle").resizable().frame(width: 24, height: 24)
                        .foregroundStyle(.red)
                        .padding(.init(top: .zero, leading: 12, bottom: .zero, trailing: 12))
                })

            }

        }.scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.doesRelativeDateFormatting = true
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    OperationView(item: .now, amount: 10, name: "Sample name")
}
