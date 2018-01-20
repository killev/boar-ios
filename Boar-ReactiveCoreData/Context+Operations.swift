//
//  Context+Operations.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import CoreData
import BrightFutures

public extension CDContext {
    func update<T:NSManagedObject>(_ type: T.Type, obj: T, update: @escaping (T) throws -> Void)-> Operation {
        
        return{ (context: NSManagedObjectContext) in
            let entity = try context.existingObject(with: obj.objectID) as! T
            try update(entity)
        }
    }
    
    func update<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, update: @escaping (T) throws -> Void)-> Operation {
        return{ (context: NSManagedObjectContext) in
            try context.find(type, pred: pred, order: [], count: nil).forEach(update)
        }
    }
    
    
    func create<T:NSManagedObject>(_ type: T.Type, setup: @escaping (T) throws -> Void)-> Operation {
        return{ (context: NSManagedObjectContext) in
            let entity = NSEntityDescription.insertNewObject(forEntityName: T.entity().name!, into: context) as! T
            try setup(entity)
        }
    }
}

extension CDContext {
    public func findAll<T:NSManagedObject>(_ type: T.Type)->Future<[T], NSError> {
        return find(type, pred: NSPredicate(value: true), order: [], count: nil)
    }
}
