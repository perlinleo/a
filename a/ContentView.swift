//
//  ContentView.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var presentingEntryView = false
    @State private var totalBalance: Decimal = 0

    private var BalanceHistoryChart: some View {
        Chart {
            ForEach(fetchBalanceHistory()) { item in
                LineMark (
                    x: .value("Label", item.timestamp),
                    y: .value("Value", item.balance)
                )
            }
        }.padding()
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 20)))
            .padding(.init(top: 12, leading: 12, bottom: 12, trailing: 12))

    }

    private var OperationHistoryScrollView: some View {
        ScrollView {
            LazyVStack {
                ForEach(items, id: \.self) { item in
                    OperationView(item: item.timestamp!, amount: item.amount as Decimal? ?? 0, name: item.name as String? ?? "")
                        .onDelete({deleteItem(item: item)})

                        .containerRelativeFrame(.vertical,
                            count: 4,
                            spacing: 10)
                        .scrollTransition(transition: { content , phase in
                            content
                                .opacity(phase.isIdentity ? 1.0 : 0)
                                .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3,
                                             y: phase.isIdentity ? 1.0 : 0.3)
                                .offset(y: phase.isIdentity ? 0 : -50)
                        })

                }
            }.scrollContentBackground(.hidden)
                .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground).ignoresSafeArea()
                VStack {
                    HStack {
                        VStack (alignment: .leading, content: {
                            TotalBalanceView(total: $totalBalance)
                        }).padding()
                        Spacer()
                        Button(action: {
                            presentingEntryView = true
                        }, label: {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                        })
                        .sheet(isPresented: $presentingEntryView) {
                            FinancialOperationEntryView(isPresented: $presentingEntryView)
                        }.padding()
                    }
                    BalanceHistoryChart
                    OperationHistoryScrollView
                    Spacer()
                }
            }.onAppear {
                totalBalance = fetchTotalBalance()
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: viewContext, queue: .main) { notification in
                    totalBalance = fetchTotalBalance()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private var totalBalanceProperty: Decimal {
        fetchTotalBalance()
    }
    private func fetchTotalBalance() -> Decimal {
        return fetchOperations().reduce(0) { sum, item in sum + ((item.amount ?? 0) as Decimal)}
    }

    private func fetchBalanceHistory() -> [BalanceHistoryEntry] {
        withAnimation {
            var currentBalance: Decimal = 0

            return fetchOperations().map({ item in
                let amount = item.amount

                currentBalance += amount as? Decimal ?? 0

                let entry = BalanceHistoryEntry(id: UUID(), timestamp: item.timestamp ?? Date(), amount: amount as? Decimal ?? 0, balance: currentBalance)
                print(entry)
                return entry
            })
        }
    }

    private func fetchOperations() -> [Item] {
        withAnimation {
            let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

            do {
                let results = try viewContext.fetch(fetchRequest)
                return results
            } catch {
                print(error.localizedDescription)
                return []
            }
        }
    }

    private func deleteItem(item: Item) {
        withAnimation {
            viewContext.delete(item)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
