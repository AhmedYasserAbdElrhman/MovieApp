//
//  CoreDataStack.swift
//  Storage
//
//  Created by Ahmad Yasser on 22/05/2025.
//

import CoreData
import OSLog

final class CoreDataStack {
    private let modelName: String
    private let bundle: Bundle
    
    // OSLog subsystem & category for this class
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CoreDataStack", category: "CoreData")
    
    /// Enable or disable logging
    var isLoggingEnabled = true
    
    // MARK: - Initialization
    
    init(modelName: String, bundle: Bundle = .main, loggingEnabled: Bool = true) {
        self.modelName = modelName
        self.bundle = bundle
        self.isLoggingEnabled = loggingEnabled
        logInfo("CoreDataStack initialized with model: \(modelName)")
    }
    
    // MARK: - Persistent Container
    
    lazy var persistentContainer: NSPersistentContainer = {
        logInfo("Loading persistent container for model: \(modelName)")
        
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to find Core Data model named \(modelName) in bundle \(bundle)")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load Core Data model at \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                self?.logError("Unresolved error loading persistent store: \(error), \(error.userInfo)")
                fatalError("Unresolved error loading persistent store: \(error), \(error.userInfo)")
            }
            self?.logInfo("Persistent store loaded: \(storeDescription)")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        return container
    }()
    
    // MARK: - Context Access
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func performOnMainContext(_ block: @escaping () -> Void) {
        logInfo("Performing block on main context")
        mainContext.perform(block)
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        logInfo("Performing background task")
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Saving
    
    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else {
            logInfo("Save skipped: no changes in context")
            return
        }
        
        do {
            try context.save()
            logInfo("Context saved successfully")
        } catch {
            logError("Failed to save context: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Logging Helpers
    
    private func logInfo(_ message: String) {
        guard isLoggingEnabled else { return }
        logger.info("\(message, privacy: .public)")
    }
    
    private func logError(_ message: String) {
        guard isLoggingEnabled else { return }
        logger.error("\(message, privacy: .public)")
    }
}
