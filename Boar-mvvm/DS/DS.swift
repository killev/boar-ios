//
//  DS.swift
//  Boar-mvvm
//
//  Created by Peter Ovchinnikov on 4/5/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_Reactive



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
