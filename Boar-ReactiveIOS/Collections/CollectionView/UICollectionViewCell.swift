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

protocol View : NSObjectProtocol  {
    var _vm : VM? { get set }
}
//
//protocol TypedView {
//    associatedtype ViewModel: VM
//    func advise(viewModel: ViewModel)
//    var viewModel: ViewModel { get }
//}
//
//protocol Reusable {
//    var reuseBag: DisposeBag{ get }
//}
//
//class ModernVC: UIViewController, TypedView, Reusable {
//    typealias ViewModel = VCService
//    
//    func advise(viewModel: VCService) {
//        
//    }
//}
//protocol ModernCell : TypedView, Reusable {
//    
//}
//class ModernCell: UICollectionViewCell, ModernCell {
//    typealias ViewModel = VCService
//    
//    func advise(viewModel: VCService) {
//        
//    }
//}

public protocol CellBase : NSObjectProtocol  {
    var _vm : CellVM? { get set }
    
}

public extension CellBase {
    static var cellIdentifier: String { return "\(type(of: self))" }
}

public protocol Cell: CellBase {
    associatedtype ViewModel: CellVM
    
    var reuseBag: DisposeBag{ get }
    var viewModel: ViewModel { get }
    func advise(viewModel: ViewModel)
}

fileprivate struct CellKeys {
    static var reuseBag = "reuseBag"
    static var viewModel = "viewModel"
}

extension Cell where Self: UICollectionViewCell {
    
    var reuseBag: DisposeBag { return dynamicROProperty(object: self, &CellKeys.reuseBag){ DisposeBag() } }
    var _vm: CellVM? {
        get{ return dynamicGetProperty(object: self, &CellKeys.viewModel) }
        set{
            var newVM: ViewModel? = nil
            guard newValue != nil else {
                dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM)
                return
            }
            newVM = newValue as? ViewModel
            dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM!)
            advise(viewModel: newVM!)
        }
    }
    var viewModel: ViewModel {
        return _vm as! ViewModel
    }
}

public extension Cell where Self: UIViewController {

    var reuseBag: DisposeBag { return dynamicROProperty(object: self, &CellKeys.reuseBag){ DisposeBag() } }
    var _vm: CellVM? {
        get{ return dynamicGetProperty(object: self, &CellKeys.viewModel) }
        set{
            var newVM: ViewModel? = nil
            guard newValue != nil else {
                dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM)
                return
            }
            newVM = newValue as? ViewModel
            dynamicSetProperty(object: self, &CellKeys.viewModel, obj: newVM!)
        }
    }
    var viewModel: ViewModel {
        return _vm as! ViewModel
    }
}


//protocol Reusable {
//    associatedtype ViewModel: VM
//    var reuseBag : DisposeBag { get }
//    func advise(viewModel: VM)
//}

extension ReactiveExtensions where Base : UICollectionViewCell, Base: Cell {
    var reuseBag: DisposeBag{ return base.reuseBag }
    var selected: DynamicSubject<Bool>{ return keyPath("selected", ofExpectedType: Bool.self)}
}
