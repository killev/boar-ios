//
//  CellVM.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation

struct dynamicProperty<O, T> {
//    func ROProperty<T>(object: Any, _ key: UnsafeRawPointer, factory: ()->T) -> T {
//        if let result = objc_getAssociatedObject(object, key) {
//            return result as! T
//        } else {
//            let result = factory()
//            objc_setAssociatedObject(object, key, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            return result
//        }
//    }
    
    private let key: UnsafeRawPointer
    private let object: O
    init(_ object: O, _ key: UnsafeRawPointer){
        self.object = object
        self.key = key
    }
    
    func value(initial:()->T) -> T {
        let anyRes = objc_getAssociatedObject(object, key) as? T
        return anyRes ?? self.value(new: initial())
    }
    
    @discardableResult
    func value(new: T) -> T {
        objc_setAssociatedObject(object, key, new, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return new
    }
   
}

func dynamicROProperty<T: AnyObject>(object: Any, _ key: UnsafeRawPointer, factory: ()->T) -> T {
    if let result = objc_getAssociatedObject(object, key) {
        return result as! T
    } else {
        let result = factory()
        objc_setAssociatedObject(object, key, result, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
}

func dynamicGetProperty<T>(object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}
func dynamicSetProperty<T>(object: Any, _ key: UnsafeRawPointer, obj: T?) {
    objc_setAssociatedObject(object, key, obj, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
