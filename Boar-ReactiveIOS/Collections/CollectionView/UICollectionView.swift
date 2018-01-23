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

extension UICollectionView {
    func register<T: CellBase>(type: T.Type) where T: UICollectionViewCell {
        let nib = UINib(nibName: T.cellIdentifier, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: T.cellIdentifier)
        
    }
}

struct DS<Item: CellVM>: CollectionViewBond {
    typealias DataSource = Array<Item>
    
    func cellForRow(at indexPath: IndexPath, collectionView: UICollectionView, dataSource: DataSource) -> UICollectionViewCell {
        
        let vm = dataSource[indexPath]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: vm.cellIdentifier, for: indexPath)
        if let reuseCell = cell as? CellBase {
            reuseCell._vm = vm
        }
        return cell
    }
}



extension Array {

    subscript(indexPath: IndexPath) -> Element {
        assert(indexPath.section == 0)
        return self[indexPath.row]
    }
}

class SimpleCellVM : CellVM {
    
}

class SimpleCell : UICollectionViewCell, Cell  {
    
    typealias ViewModel = SimpleCellVM
    func advise(viewModel: SimpleCellVM) {
    }
}

func f() {
    let collectionView = UICollectionView()
    collectionView.register(type: SimpleCell.self)
    let observableArray = ObservableArray<SimpleCellVM>([])
   observableArray.bind(to: collectionView, using: DS())
}
