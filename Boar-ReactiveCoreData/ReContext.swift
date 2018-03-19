//
//  ReContext.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 2/2/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import RealmSwift
import Boar_Reactive

final public class ReContext {
    let realm = try! Realm()
    
    public func find<T:Object>(_ type: T.Type, pred: NSPredicate, order: [(String,Bool)], count: Int?)->Future<[T]> {
        
        let res:Array<T> = realm.objects(T.self).filter(pred).map{ $0 as T }
        
        return Future(value: res)
    }
    
}
