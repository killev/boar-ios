//
//  File.swift
//  Boar-ReactiveCoreDataTests
//
//  Created by Peter Ovchinnikov on 2/2/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_ReactiveCoreData
import Bond


extension TestEntity : DBEntityProtocol{
 
    public func patch(with patch: Dictionary<String, Any?>) -> Self {
        patch.forEach { self.setValue($1, forKey: $0) }
        return self
    }
}

extension ReactiveExtensions where Base == TestEntity {
    var id: DynamicSubject2<UUID>{
        return reactive.keyPath("id", ofExpectedType: UUID.self, context: .immediate)
    }
    var url: DynamicSubject2<UUID>{
        return reactive.keyPath("url", ofExpectedType: UUID.self, context: .immediate)
    }
}

//struct CDTestEntity : DBEntityProtocol {
//
//    typealias Entity = TestEntity
//
//    var model: TestEntity
//
//    init(model: TestEntity) {
//        self.model = model
//    }
//
//    var id: DynamicSubject2<UUID>{
//        return model.reactive.keyPath("id", ofExpectedType: UUID.self, context: .immediate)
//    }
//    var url: DynamicSubject2<UUID>{
//        return model.reactive.keyPath("url", ofExpectedType: UUID.self, context: .immediate)
//    }
//}
//

