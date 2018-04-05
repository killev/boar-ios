//
//  NSLayoutConstraint.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 4/5/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation

extension ReactiveExtensions where Base: NSLayoutConstraint {
    var constant: Bond<CGFloat>{
        return self.bond(setter: { (ctrl, value) in
            ctrl.constant = value
        })
    }
}

extension NSLayoutConstraint: BindableProtocol {
    
    public func bind(signal: Signal<CGFloat>) -> Disposable {
        return reactive.constant.bind(signal: signal)
    }
}

#endif
