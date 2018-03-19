//
//  File.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import CoreData



extension NSManagedObjectContext {
    
    @discardableResult
    func async<T>(_ block: @escaping (_ context:NSManagedObjectContext) throws -> T) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        self.perform{
            promise.materialize{ try block(self) }
        }
        return promise.future
    }
    
    @discardableResult
    func async<T>(_ block: @escaping (_ context:NSManagedObjectContext) -> Future<T, NSError>) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        self.perform{
            promise.completeWith( block(self) )
        }
        return promise.future
    }
    
    @discardableResult
    func transaction<T>(_ block: @escaping (_ context:NSManagedObjectContext) throws -> T) -> Future<T, NSError> {
        return self.async{ context in
            do  {
                let res = try block(context)
                try context.save()
                return res
            } catch {
                context.rollback()
                throw error
            }
        }
    }
    
    @discardableResult
    func sync<T>(_ block: (_ context:NSManagedObjectContext) -> T)  -> T {
        var res: T!
        self.performAndWait{
            res = block(self)
        }
        return res
    }
    
    
    @discardableResult
    func sync<T>(_ block: (_ context:NSManagedObjectContext) throws -> T) throws -> T{
        var res: Result<T,NSError>!
        self.performAndWait{
            res = Result<T,NSError>(attempt: { try block(self)} )
        }
        if let val = res.value {
            return val
        }
        else {
            throw res.error!
        }
    }
}

internal extension NSManagedObject {
    class func entityName()->String {
        print (type(of: self.entity()))
        return self.entity().name!
    }
}

internal extension NSManagedObjectContext {
    convenience init(parent: NSManagedObjectContext, merge: Bool) {
        self.init(concurrencyType: .privateQueueConcurrencyType)
        self.parent = parent
        self.automaticallyMergesChangesFromParent = true
    }
    func fork(merge: Bool) -> NSManagedObjectContext {
        return NSManagedObjectContext(parent: self, merge: merge)
    }
    
    func find<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?) throws  -> [T] {
        
        let request = NSFetchRequest<T>(entityName: T.entityName())
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
