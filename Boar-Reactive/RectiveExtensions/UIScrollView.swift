//
//  UIScrollView.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 4/5/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

#if os(iOS) || os(tvOS)

extension ReactiveExtensions where Base: UIScrollView {
    var contentSize: Signal1<CGSize>{
        return keyPath(\.contentSize)
    }
}

#endif
