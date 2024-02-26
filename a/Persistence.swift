//
//  Persistence.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import CoreData

struct BalanceHistoryEntry: Identifiable {
    var id: UUID
    let timestamp: Date
    let amount: Decimal
    let balance: Decimal
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var randomPurchaseName: String {
        ["book", "shirt", "coffee", "ticket", "subscription"].randomElement()!
    }

    static var randomPurchaseDate: Date {
        let calendar = Calendar.current

        var components = DateComponents(year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()) - 1)
        components.day = Int.random(in: 1...28)
        components.hour = Int.random(in: 0...23)
        components.minute = Int.random(in: 0...59)
        
        return calendar.date(from: components) ?? Date()
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = randomPurchaseDate
            newItem.name = randomPurchaseName
            newItem.amount = NSDecimalNumber(value: Double.random(in: -1000...10000))
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "a")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    
}
