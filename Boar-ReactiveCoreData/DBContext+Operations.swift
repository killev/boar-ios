//
//  File.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 2/2/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import BrightFutures
import CoreData
public extension DBContext {
    
    public func find<T:DBEntityProtocol>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?)->Future<[T], NSError> where T : CoreDataDriver.Entity {
        return driver.find(T.self, pred: pred, order: order, count: count)
    }
    
    public func findAll<T:DBEntityProtocol>(_ type: T.Type)->Future<[T], NSError> where T : Entity {
        return find(type, pred: NSPredicate(value: true), order: [], count: nil)
    }
    
    
    public struct ChangedContext {
        public let inserted: Set<NSManagedObject>
        public let updated: Set<NSManagedObject>
        public let deleted: Set<NSManagedObject>
    }
    
    public static func create<T:DBEntityProtocol>(_ type: T.Type, setup: @escaping (T) throws -> T)-> Operation  where T : Entity {
        
        return CoreDataDriver.create(T.self, setup: setup)
    }
    
    public func perform(operations: @escaping () -> [Operation]) -> Future<DBContext.ChangedContext, NSError> {
        return driver.perform(operations: operations)
    }
    
    public func delete(){
        driver.delete()
    }
    
    public func fetch<T: DBEntityProtocol>(_ type: T.Type, initial: NSPredicate, order: [(String,Bool)])-> CoreDataFetchedObservable<T> where T: Entity{
        return driver.fetch(type, initial: initial, order: order)
    }
    
    static func update<T: DBEntityProtocol>(_ type: T.Type, obj: T, update: @escaping (T) throws -> T)-> Operation where T : Entity {
        
        return CoreDataDriver.update(type, obj: obj, update: update)
        
    }
    
    static func update<T:DBEntityProtocol>(_ type: T.Type, pred: NSPredicate, update: @escaping (T) throws -> T)-> Operation where T : Entity {
        
        return CoreDataDriver.update(type, pred: pred, update:update)
    }
    
    static func delete<T:DBEntityProtocol>(_ type: T.Type, obj: T)-> Operation where T : CoreDataDriver.Entity {
        
        return CoreDataDriver.delete(type, obj: obj)
        
    }
    
    static func delete<T:DBEntityProtocol>(_ type: T.Type, pred: NSPredicate)-> Operation where T : Entity {
        
        return CoreDataDriver.delete(type, pred: pred)
    }
}
