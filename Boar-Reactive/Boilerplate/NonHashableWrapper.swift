//
//  NonHashableWrapper.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 4/6/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation

public class NonHashableWrapper<T>{
    public let object:T
    public init(_ object: T){
        self.object = object
    }
}
