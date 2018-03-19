//
//  CoreDataDriver.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 2/2/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import CoreData
import Boar_Reactive

protocol DataDriver {
    associatedtype Entity
    associatedtype Operation 
}

public final class CoreDataDriver {
    
    public typealias Entity = NSManagedObject
    public typealias Operation = (NSManagedObjectContext) throws -> Void
    
    private var managedObjectModel : NSManagedObjectModel
    private var coordinator : NSPersistentStoreCoordinator
    
    
    private let coordinatorQueue = DispatchQueue(label: "com.boar.core-data-coordinator-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    private let backgroundQueue = DispatchQueue(label: "com.boar.core-data-background-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    internal var сoordinatorContext : NSManagedObjectContext!
    internal var backgroundContext : NSManagedObjectContext!
    private var store: NSPersistentStore
    
    public init(_ modelURL:URL, sqliteURL:URL) throws {
        assert(Thread.isMainThread, "init should be called from main thread only")
        
        
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        coordinator        = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        //let container = NSPersistentContainer(name: "Name", managedObjectModel: managedObjectModel)
        
        store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        
        coordinatorQueue.sync {
            self.сoordinatorContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.сoordinatorContext.persistentStoreCoordinator = self.coordinator
        }
        
        
        backgroundQueue.sync {
            self.backgroundContext = self.сoordinatorContext.fork(merge: true)
        }
        
        
    }
    
    internal func delete(){
        if let url = store.url {
            try? coordinator.persistentStores.forEach(coordinator.remove)
            try? FileManager.default.removeItem(at: url)
        }
    }
    public func find<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?)->Future<[T]> {
        return backgroundContext.async{ context in
            return try context.find(type, pred: pred, order: order, count: count)
        }
    }
    
    public func perform(operations: @escaping () -> [Operation] ) -> Future<DBContext.ChangedContext>{
        return сoordinatorContext.transaction{context -> DBContext.ChangedContext in
            try operations().forEach{ try $0(context) }
            return DBContext.ChangedContext(inserted: context.insertedObjects,
                                  updated: context.updatedObjects,
                                  deleted: context.deletedObjects)
        }
    }
    
    func fetch<T:NSManagedObject>(_ type: T.Type, initial: NSPredicate, order: [(String,Bool)]) -> CoreDataFetchedObservable<T> {
        return CoreDataFetchedObservable(parent: сoordinatorContext,initial: initial, order: order)
    }
}
