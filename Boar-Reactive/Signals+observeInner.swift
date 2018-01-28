//
//  Signals+observeInner.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 1/26/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import ReactiveKit

public extension SignalProtocol where Element: Sequence {
    public typealias Item = Element.Element
    func observeInner<T:SignalProtocol>(f: @escaping (Item)->T)->Signal<Element, Error> where T.Error == NoError {
        
        return Signal{ observer in
            
            let innerDisposable = SerialDisposable(otherDisposable: nil)
            let outerDisposable = CompositeDisposable([innerDisposable])
            let lock = NSRecursiveLock(name: "com.reactivekit.observeInner")
            
            outerDisposable += self.observe{ event in
                lock.lock()
                switch event {
                    
                case .next(let element):
                    innerDisposable.otherDisposable?.dispose()
                    
                    var inside = true
                    innerDisposable.otherDisposable = element.reduce(CompositeDisposable()) {
                        $0 += f($1).filter{ _ in !inside }
                            .map{_ in element }
                            .observeNext(with: observer.next)
                        return $0
                    }
                    observer.next(element)
                    inside = false
                    
                case .failed(let error):
                    observer.failed(error)
                    
                case .completed:
                    observer.completed()
                    
                }
                lock.unlock()
            }
            return outerDisposable
        }
    }
}
