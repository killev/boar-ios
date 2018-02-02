//
//  CDObject.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/31/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation



public protocol DBEntityProtocol {
    //associatedtype Entity : EntityType
    //var model: Entity { get }
    //init(model: Entity)
    func patch(with patch: Dictionary<String, Any?>)->Self
}

//public extension DBEntityProtocol {
//    func patch(with patch: Entity.Patch)->Self {
//        return Self.init(model: model.patch(with: patch))
//    }
//}


