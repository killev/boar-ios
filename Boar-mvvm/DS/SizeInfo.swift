//
//  SizeInfo.swift
//  Boar-mvvm
//
//  Created by Peter Ovchinnikov on 4/5/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation

public enum ValueInfo {
    case const(CGFloat)
    case percent(CGFloat)
    case denom(num: Int)
    case full(offset: CGFloat )
    case equal
}

extension ValueInfo {
    func value(from container: CGFloat) -> CGFloat {
        switch self {
        case .full(let offset): return container - offset
        case .const(let value): return value
        case .percent(let value): return container * value
        case .equal: fatalError()
        case .denom(let num): return container / CGFloat(num)
        }
    }
}

public enum SizeInfo {
    case value(width: ValueInfo, height: ValueInfo)
    case custom( (CGSize)->CGSize)
}

public extension SizeInfo {
    
    init (width: ValueInfo = ValueInfo.full(offset: 0), height:ValueInfo  = ValueInfo.const(75)) {
        self = .value(width: width, height: height)
    }
    init (size: @escaping (CGSize)->CGSize) {
        self = .custom(size)
    }
}

extension SizeInfo {
    func size(from container: CGSize) -> CGSize {
        switch self {
        case .value(let _width, let _height):
            var height: CGFloat = 0, width: CGFloat = 0
            if case .equal = _height {
                width = _width.value(from: container.width)
                height = width
                
            }else if case .equal = _width {
                height = _height.value(from: container.height)
                width = height
            }else {
                width = _width.value(from: container.width)
                height = _height.value(from: container.height)
            }
            return CGSize(width: width, height: height)
        case .custom(let f):
            return f(container)
        }
    }
}
