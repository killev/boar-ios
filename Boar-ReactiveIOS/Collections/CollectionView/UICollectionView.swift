//
//  CollectionView.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/22/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

protocol CellConfigurer {
    func confugure(cell: UICollectionViewCell)
}
public protocol Configurable {
    associatedtype Config
    func configure(with: Config)
}

class TypedConfigurer<Cell: Configurable> : CellConfigurer where Cell: UICollectionViewCell {
    let config : Cell.Config
    
    init(config: Cell.Config) {
        self.config = config
    }
    func confugure(cell: UICollectionViewCell) {
        if let cell = cell as? Cell {
            cell.configure(with: config)
        }
    }
}
class NonHashableWrapper<T>{
    let object:T
    init(_ object: T){
        self.object = object
    }
}


public extension UICollectionView {

    static var configurersKey = "configurersKey"
    
    fileprivate var configurers: Dictionary<String, CellConfigurer> {
        get {
            return dynamicProperty(self, &UICollectionView.configurersKey)
                .value(initial: { NonHashableWrapper([:]) }).object
           
        }
        set {
            dynamicProperty(self, &UICollectionView.configurersKey)
                .value(new: NonHashableWrapper(newValue))
        }
    }
    
    func register<T: UICollectionViewCell>(_ type: T.Type) {
        let cellId = "\(type)"
        let nib    = UINib(nibName: cellId, bundle: Bundle.main)
        self.register(nib, forCellWithReuseIdentifier: cellId)
    }
    
    func register<T: UICollectionViewCell>(_ type: T.Type, with config: T.Config) where T: Configurable {
        configurers["\(type)"] = TypedConfigurer<T>(config: config)
        self.register(type)
        
    }
    func dequeue(identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        configurers["\(type(of: cell))"]?.confugure(cell: cell)
        return cell
    }
    
    func dequeue<T:UICollectionViewCell>(_ _type: T.Type, for indexPath: IndexPath) -> T {
        return dequeue(identifier: "\(_type)", for: indexPath) as! T
    }
}


protocol CellAdviser {
    var cellIdetifier: String { get }
    func advise(cell: UICollectionViewCell, vm: VM)
}

class TypedCellAdviser<T:VM, C: Cell >: CellAdviser  where C: UICollectionViewCell, C.ViewModel == T {

    let cellIdetifier: String = ""
    
    func advise(cell: UICollectionViewCell, vm: VM) {
        if let typedCell = cell as? C, let typedVM = vm as? T {
            typedCell.reuseBag.dispose()
            typedCell.advise(vm: typedVM)
        }
    }
}


enum ValueInfo {
    case const(CGFloat)
    case percent(CGFloat)
    case denom(num: Int)
    case full
    case equal
}

extension ValueInfo {
    func value(from container: CGFloat) -> CGFloat {
        switch self {
        case .full: return container
        case .const(let value): return value
        case .percent(let value): return container * value
        case .equal: fatalError()
        case .denom(let num): return container / CGFloat(num)
        }
    }
}

struct SizeInfo {
    let width: ValueInfo
    let height: ValueInfo
    init (width: ValueInfo  = ValueInfo.full, height:ValueInfo  = ValueInfo.const(75)) {
        self.width = width
        self.height = height
    }
}



extension SizeInfo {
    func size(from container: CGSize) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if case .equal = self.height {
            width = self.width.value(from: container.width)
            height = width
            
        }else if case .equal = self.width {
            height = self.height.value(from: container.height)
            width = height
        }else {
            width = self.width.value(from: container.width)
            height = self.height.value(from: container.height)
        }
        
        return CGSize(width: width, height: height)
        
    }
}

struct DataInfo {
    
}

public struct DS<Item: VM>: CollectionViewBond {
    func register<T:VM, C: Cell>(vm: T.Type,  cell: C.Type) where C: UICollectionViewCell, C.ViewModel == T {
        
    }
    
    
    func register<T, C: Cell, V: VM>(data: T.Type,  cell: C.Type, lazy: (T)->V) where C: UICollectionViewCell, C.ViewModel == T {
        
        
        
    }
    
    
    public typealias DataSource = Array<Item>
    private var advisers = Dictionary<String, CellAdviser>()
   
    public func cellForRow(at indexPath: IndexPath, collectionView: UICollectionView, dataSource: DataSource) -> UICollectionViewCell {
        
        let vm = dataSource[indexPath]
        let adviser = advisers["\(type(of: vm))"]!
        
        let cell = collectionView.dequeue(identifier: adviser.cellIdetifier, for: indexPath)
        adviser.advise(cell: cell, vm: vm)
        
        return cell
    }
}



extension Array {
    subscript(indexPath: IndexPath) -> Element {
        assert(indexPath.section == 0)
        return self[indexPath.row]
    }
}
