//
//  File.swift
//  Boar-mvvm
//
//  Created by Peter Ovchinnikov on 4/6/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_Reactive


fileprivate struct Keys {
    static var bag = "bag"
    static var reuseBag = "reuseBag"
    static var viewModel = "viewModel"
}

public protocol View: NSObjectProtocol  {
    associatedtype ViewModel
    func advise(vm: ViewModel)
}

public typealias ReuseView = View & ReuseDisposeBagProvider

public protocol Cell: ReuseView {
    
}

public protocol Controller: View {
    
}

public extension ReuseDisposeBagProvider where Self: ReuseView {
    var reuseBag: DisposeBag { return DynamicProperty(self, &Keys.reuseBag).value{ DisposeBag () } }
}

public extension DisposeBagProvider where Self: VM {
    var bag: DisposeBag { return DynamicProperty(self, &Keys.bag).value{ DisposeBag () } }
}

public extension ReactiveExtensions where Base : UICollectionViewCell, Base: Cell {
    var reuseBag: DisposeBag{ return base.reuseBag }
    var selected: DynamicSubject<Bool>{ return keyPath("selected", ofExpectedType: Bool.self)}
}
