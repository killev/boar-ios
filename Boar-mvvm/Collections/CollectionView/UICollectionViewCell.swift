//
//  File.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_Reactive

public protocol ReuseDisposeBagProvider {
    var reuseBag: DisposeBag { get }
}


fileprivate struct Keys {
    static var bag = "bag"
    static var reuseBag = "reuseBag"
    static var viewModel = "viewModel"
}

public protocol View: NSObjectProtocol  {
    associatedtype ViewModel
    func advise(vm: ViewModel)
}

public protocol Cell: View, ReuseDisposeBagProvider {
    
}

public protocol Controller: View {
    
}

public extension ReuseDisposeBagProvider where Self: View {
   var reuseBag: DisposeBag { return DynamicProperty(self, &Keys.reuseBag).value{ DisposeBag () } }
}

public extension DisposeBagProvider where Self: VM {
    var bag: DisposeBag { return DynamicProperty(self, &Keys.bag).value{ DisposeBag () } }
}


public extension ReactiveExtensions where Base : UICollectionViewCell, Base: Cell {
    var reuseBag: DisposeBag{ return base.reuseBag }
    var selected: DynamicSubject<Bool>{ return keyPath("selected", ofExpectedType: Bool.self)}
}
