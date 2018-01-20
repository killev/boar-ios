//
//  CoreDataContext.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures
import Boar_Reactive


extension Promise {
    func materialize(_ f: (() throws -> T) ){
        do {
            success(try f())
        }catch {
            failure(error as! E)
        }
    }
}


extension NSManagedObjectContext{
    
    fileprivate func async<T>(_ block: @escaping (_ context:NSManagedObjectContext) throws -> T) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        self.perform{
            promise.materialize{ try block(self) }
        }
        return promise.future
    }
    
    fileprivate func transaction<T>(_ block: @escaping (_ context:NSManagedObjectContext) throws -> T) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        self.perform{
            do  {
                let res = try block(self)
                try self.save()
                promise.success(res)
            } catch {
                self.rollback()
                promise.failure(error as NSError)
            }
        }
        return promise.future
    }
    
    fileprivate func sync<T>(_ block: @escaping (_ context:NSManagedObjectContext) -> T) -> T{
        var res: T!
        self.performAndWait{ res = block(self) }
        return res
    }
}

final public class CDContext {
    
    private var managedObjectModel : NSManagedObjectModel
    private var coordinator : NSPersistentStoreCoordinator
    
    
    private let coordinatorQueue = DispatchQueue(label: "com.boar.core-data-coordinator-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    private let backgroundQueue = DispatchQueue(label: "com.boar.core-data-background-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    private var сoordinatorContext : NSManagedObjectContext!
    private var backgroundContext : NSManagedObjectContext!
    private var store: NSPersistentStore
    public init(_ modelURL:URL, sqliteURL:URL) throws {
        assert(Thread.isMainThread, "init should be called from main thread only")
        
        
        managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        coordinator        = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        
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
    
    public func remove(){
        if let url = store.url {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    public typealias Operation = (NSManagedObjectContext) throws -> Void
    public struct ChangedContext {
        public let inserted: Set<NSManagedObject>
        public let updated: Set<NSManagedObject>
        public let deleted: Set<NSManagedObject>
    }
    @discardableResult
    public func perform(operations: @escaping (CDContext) throws ->[Operation] ) -> Future<CDContext.ChangedContext, NSError>{
        return сoordinatorContext.transaction{context -> CDContext.ChangedContext in
            try operations(self).forEach{ try $0(context) }
            return ChangedContext(inserted: context.insertedObjects,
                                  updated: context.updatedObjects,
                                  deleted: context.deletedObjects)
        }
    }
    
    public func find<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?)->Future<[T], NSError> {
        return backgroundContext.async{ context in
            return try context.find(type, pred: pred, order: order, count: count)
        }
    }
}

internal extension NSManagedObjectContext {
    func find<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?) throws  -> [T] {
 
        let request = NSFetchRequest<T>(entityName: T.entity().name!)
        request.predicate = pred
        
        var sortDesriptors = [NSSortDescriptor]()
        for (sortTerm, ascending) in order {
            sortDesriptors.append(NSSortDescriptor(key: sortTerm, ascending: ascending))
        }
        request.sortDescriptors = sortDesriptors
        if let count = count {
            request.fetchLimit = count
        }
        
        let objects = try! fetch(request)
        return objects
    }
}

