//
//  CoreDataContext.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import CoreData


final public class CDContext {
    
    private var managedObjectModel : NSManagedObjectModel
    private var coordinator : NSPersistentStoreCoordinator
    
    
    private let coordinatorQueue = DispatchQueue(label: "com.boar.core-data-coordinator", attributes: DispatchQueue.Attributes())
    private let backgroundQueue = DispatchQueue(label: "com.boar.core-data-background", attributes: DispatchQueue.Attributes())
    
    
    private var сoordinatorContext : NSManagedObjectContext!
    private var backgroundContext : NSManagedObjectContext!
    
    public init(_ modelURL:URL, sqliteURL:URL) throws {
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        coordinator        = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        
        coordinatorQueue.sync {
            self.сoordinatorContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.сoordinatorContext.persistentStoreCoordinator = self.coordinator
        }
        
        backgroundQueue.sync {
            self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.backgroundContext.parent = self.сoordinatorContext
            self.backgroundContext.automaticallyMergesChangesFromParent = true
        }
    }
}

