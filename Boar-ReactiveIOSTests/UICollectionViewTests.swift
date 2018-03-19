//
//  Boar_ReactiveIOSTests.swift
//  Boar-ReactiveIOSTests
//
//  Created by Peter Ovchinnikov on 1/22/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import XCTest
import Boar_ReactiveIOS

class SuperVM: VM {
    
}

class SuperCell : UICollectionViewCell, Cell {
    
    func advise(vm: SuperVM) {
        
    }

    typealias ViewModel = SuperVM
    
}

class UICollectionViewTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        UIViewController.setup()
        
        let arr = MutableObservableArray<VM>([])
        let ds = DS<String>()
    
        let collectionView = UICollectionView()
        collectionView.register(SuperCell.self)
        
//        collectionView.register(SuperCell.self)
//        arr.bind(to: collectionView, using: ds)

    }
    
}

