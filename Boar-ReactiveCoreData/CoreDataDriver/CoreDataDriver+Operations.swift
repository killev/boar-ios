//
//  Context+Operations.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import CoreData
import BrightFutures

public extension CoreDataDriver {
    static func update<T:NSManagedObject>(_ type: T.Type, obj: T, update: @escaping (T) throws -> T)-> Operation {
        
        return { (context: NSManagedObjectContext) in
            let entity = obj.managedObjectContext == context ? obj : try context.existingObject(with: obj.objectID) as! T
            _ = try update(entity)
        }
    }
    
    static func update<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate, update: @escaping (T) throws -> T)-> Operation {
        return { (context: NSManagedObjectContext) in
            try context.find(type, pred: pred, order: [], count: nil).forEach{_ = try update($0) }
        }
    }
    
    static func delete<T:NSManagedObject>(_ type: T.Type, obj: T)-> Operation {
        
        return { (context: NSManagedObjectContext) in
            let entity = obj.managedObjectContext == context ? obj : try context.existingObject(with: obj.objectID) as! T
            context.delete(entity)
        }
    }
    
    static func delete<T:NSManagedObject>(_ type: T.Type, pred: NSPredicate)-> Operation {
        return { (context: NSManagedObjectContext) in
            try context.find(type, pred: pred, order: [], count: nil).forEach(context.delete)
        }
    }
    
    
    static func create<T:NSManagedObject>(_ type: T.Type, setup: @escaping (T) throws -> T)-> Operation {
        return { (context: NSManagedObjectContext) in
            print(T.self)
            let entity = NSEntityDescription.insertNewObject(forEntityName: T.entityName(), into: context) as! T
            _ = try setup(entity)
        }
    }
}


