//
//  TestEntity.swift
//  Boar-ReactiveCoreDataTests
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Bond
import ReactiveKit
import Boar_ReactiveCoreData
import CoreData

class TestEntity : NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestEntity> {
        return NSFetchRequest<TestEntity>(entityName: "TestEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var url: String?
}


public protocol CDTestEntity : CDObject {
    
}

extension TestEntity : CDTestEntity  {
   
}
extension ReactiveExtensions where Base == TestEntity {
    public var id: DynamicSubject2<UIID>{
        return keyPath("id", ofExpectedType: UUID.self, context: .immediate)
    }
}
