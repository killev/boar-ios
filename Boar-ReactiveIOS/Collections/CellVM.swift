//
//  CellVM.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation

public protocol CellVM : VM  {
    
}

public extension CellVM {
    var cellIdentifier: String {  return "\(type(of: self))"}
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
