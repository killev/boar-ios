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




