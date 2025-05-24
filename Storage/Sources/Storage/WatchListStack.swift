//
//  WatchListStack.swift
//  Storage
//
//  Created by Ahmad Yasser on 23/05/2025.
//


import CoreData
import OSLog

public final class WatchListStack {
    // MARK: - Properties
    @MainActor
    public static let shared = WatchListStack()

    private let coreDataStack: CoreDataStack
    
    // You can expose main context if needed
    public var mainContext: NSManagedObjectContext {
        coreDataStack.mainContext
    }
    
    // MARK: - Initialization
    
    /// Initialize WatchListStack with model name and bundle (e.g. SPM package bundle)
    private init(modelName: String = "WatchListDataFile", loggingEnabled: Bool = true) {
        coreDataStack = CoreDataStack(
            modelName: modelName,
            bundle: Bundle.module,
            loggingEnabled: loggingEnabled
        )
    }
    
    // MARK: - Core Data Operations
    
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        coreDataStack.performBackgroundTask(block)
    }
    
    public func performOnMainContext(_ block: @escaping () -> Void) {
        coreDataStack.performOnMainContext(block)
    }
    
    public func save(context: NSManagedObjectContext) throws {
        try coreDataStack.save(context: context)
    }
    
    // MARK: - Logging Control
    
    var isLoggingEnabled: Bool {
        get { coreDataStack.isLoggingEnabled }
        set { coreDataStack.isLoggingEnabled = newValue }
    }
}
