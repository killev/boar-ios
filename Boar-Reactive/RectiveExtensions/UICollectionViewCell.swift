//
//  UICollectionViewCell.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 4/5/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation

extension ReactiveExtensions where Base: UICollectionViewCell {
    var didSelect: SafeSignal<Void> {
        return isSelected.filter{ $0 }.eraseType()
    }
    public var isSelected: DynamicSubject<Bool> {
        return keyPath("selected", ofExpectedType: Bool.self)
    }
}

#endif
