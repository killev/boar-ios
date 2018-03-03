//
//  File.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond


public protocol ReuseDisposeBagProvider {
    var reuseBag: DisposeBag { get }
}

public protocol Cell: NSObjectProtocol, ReuseDisposeBagProvider  {
    associatedtype ViewModel
    func advise(vm: ViewModel)
}

fileprivate struct CellKeys {
    static var reuseBag = "reuseBag"
    static var viewModel = "viewModel"
}




//public extension Cell where Self: UICollectionViewCell {
//}
//
//public extension Cell where Self: UIViewController {
//
//    var reuseBag: DisposeBag { return dynamicROProperty(object: self, &CellKeys.reuseBag){ DisposeBag() } }
//    var _vm: CellVM? {
//        get{ return dynamicGetProperty(object: self, &CellKeys.viewModel) }
//        set{
//            var newVM: ViewModel? = nil
//            guard newValue != nil else {
//                dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM)
//                return
//            }
//            newVM = newValue as? ViewModel
//            dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM!)
//        }
//    }
//    var viewModel: ViewModel {
//        return _vm as! ViewModel
//    }
//}


//protocol Reusable {
//    associatedtype ViewModel: VM
//    var reuseBag : DisposeBag { get }
//    func advise(viewModel: VM)
//}

public extension ReactiveExtensions where Base : UICollectionViewCell, Base: Cell {
    var reuseBag: DisposeBag{ return base.reuseBag }
    var selected: DynamicSubject<Bool>{ return keyPath("selected", ofExpectedType: Bool.self)}
}
