import SwiftUI
import CoreData

@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var paymentManager: PaymentManager
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _paymentManager = StateObject(wrappedValue: PaymentManager(context: context))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(paymentManager)
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PaymentModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data store: \(error.localizedDescription)")
            }
        }
        
        // Configure the context to automatically merge changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func resetStore() {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            do {
                try coordinator.remove(store)
                try coordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
            } catch {
                print("Error removing or destroying persistent store: \(error.localizedDescription)")
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error reloading store: \(error.localizedDescription)")
            }
        }
    }

}
