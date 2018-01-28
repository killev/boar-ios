//
//  Boar_ReactiveIOSTests.swift
//  Boar-ReactiveIOSTests
//
//  Created by Peter Ovchinnikov on 1/22/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import XCTest
import Boar_ReactiveIOS



public class ModernCtrlVC: VCService {
    public func reload() {
        
    }
    public func reload(code: String) {
        
    }
}


public class ModernCtrl: UIViewController, VCLifeCycle, Cell {
    
    public func advise(viewModel: ModernCtrlVC) {
        
    }
    
    public typealias ViewModel = ModernCtrlVC
}

class UIViewControllerTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        UIViewController.setup()
        let ctrl = ModernCtrl()
        ctrl._vm = ModernCtrlVC()
        let v = ctrl.view
        ctrl.loadView()
    }
    
}
