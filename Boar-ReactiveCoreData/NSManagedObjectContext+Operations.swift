//
//  File.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import CoreData
import BrightFutures

extension NSManagedObjectContext {
    
    //@discardableResult
    func async<T>(_ block: @escaping (_ context:NSManagedObjectContext) throws -> T) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        self.perform{
            promise.materialize{ try block(self) }
        }
        return promise.future
    }
    
    func async(_ block: @escaping (_ context:NSManagedObjectContext) -> Void) {
        self.perform{ block(self) }
    }
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
        
    
    func sync<T>(_ block: (_ context:NSManagedObjectContext) -> T) -> T{
        var res: T!
        self.performAndWait{ res = block(self) }
        return res
    }
}
