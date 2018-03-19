//
//  CoreDataContext.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import CoreData
import Boar_Reactive



final public class DBContext {
    
    public typealias Entity = CoreDataDriver.Entity
    public typealias Operation = CoreDataDriver.Operation
    
    init(driver: CoreDataDriver){
        self.driver = driver
    }
    
    internal let driver: CoreDataDriver
}


public extension DBContext {
    convenience init(_ modelURL:URL, sqliteURL:URL) throws{
        let driver = try CoreDataDriver(modelURL, sqliteURL: sqliteURL)
        self.init(driver: driver)
    }
}





