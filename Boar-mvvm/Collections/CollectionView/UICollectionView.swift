//
//  CollectionView.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/22/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import UIKit
import Boar_Reactive

public protocol Configurable {
    associatedtype Config
    func configure(with: Config)
}

typealias Configurer = (UICollectionViewCell)->()

class NonHashableWrapper<T>{
    let object:T
    init(_ object: T){
        self.object = object
    }
}


extension UICollectionView {

    static var configurersKey = "configurersKey"
    
    fileprivate var configurers: Dictionary<String, Configurer> {
        get {
            return DynamicProperty(self, &UICollectionView.configurersKey)
                .value(initial: { NonHashableWrapper([:]) }).object
           
        }
        set {
            DynamicProperty(self, &UICollectionView.configurersKey)
                .value(new: NonHashableWrapper(newValue))
        }
    }
    
    public func register<T: UICollectionViewCell>(_ type: T.Type) {
        let cellId = "\(type)"
        let nib    = UINib(nibName: cellId, bundle: Bundle.main)
        self.register(nib, forCellWithReuseIdentifier: cellId)
    }
    
    public func register<T: UICollectionViewCell>(_ type: T.Type, with configurer: @escaping (T)->()) {
        configurers["\(type)"] = { (cell: UICollectionViewCell) in
            configurer(cell as! T)
        }
        self.register(type)
    }
    
    public func register<T: UICollectionViewCell>(_ type: T.Type, with config: T.Config) where T: Configurable {
        register(type){ $0.configure(with: config) }
    }
    
    public func dequeue(identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        configurers["\(type(of: cell))"]?(cell)
        return cell
    }
    
    public func dequeue<T:UICollectionViewCell>(_ _type: T.Type, for indexPath: IndexPath) -> T {
        return dequeue(identifier: "\(_type)", for: indexPath) as! T
    }
}

public enum ValueInfo {
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

public struct SizeInfo {
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

struct DataInfo<Item> {
    let cell: UICollectionViewCell.Type
    let sizeInfo: SizeInfo
    let adviser: (UICollectionViewCell, Item)->()
    
}

public class DS<Item>: CollectionViewBond {
    
    func register<T, C: UICollectionViewCell>(data: T.Type, cell: C.Type, sizeInfo: SizeInfo, adviser: @escaping (C, T)->() )  {
        dataInfo["\(data)"] = DataInfo<Item>(cell: cell, sizeInfo: sizeInfo) { (cell: UICollectionViewCell, item: Item) in
            adviser(cell as! C, item as! T)
        }
    }
    public init(){
        
    }
    public func register<C: UICollectionViewCell>(cell: C.Type, sizeInfo: SizeInfo) where C: Cell  {
        register(data: C.ViewModel.self, cell: C.self, sizeInfo: sizeInfo) { cell, vm in
            cell.reuseBag.dispose()
            cell.advise(vm: vm)
        }
    }

    public func register<T,C: UICollectionViewCell>(data:T.Type, cell: C.Type, sizeInfo: SizeInfo, factory: @escaping (T)->C.ViewModel) where C: Cell  {
        
        register(data: data, cell: cell, sizeInfo: sizeInfo, adviser: { cell, vm in
            cell.reuseBag.dispose()
            cell.advise(vm: factory(vm))
        })
    
    }
    
    public typealias DataSource = Array<Item>
    private var dataInfo = Dictionary<String, DataInfo<Item>>()
   
    public func cellForRow(at indexPath: IndexPath, collectionView: UICollectionView, dataSource: DataSource) -> UICollectionViewCell {
        
        let vm = dataSource[indexPath]
        guard let info = dataInfo["\(type(of: vm))"] else {
            fatalError("Unregistered data typf of: \(type(of: vm))")
        }
        let cell = collectionView.dequeue(identifier: "\(info.cell)", for: indexPath)
        info.adviser(cell, vm)
        
        return cell
    }
}

extension Array {
    subscript(indexPath: IndexPath) -> Element {
        assert(indexPath.section == 0)
        return self[indexPath.row]
    }
}
