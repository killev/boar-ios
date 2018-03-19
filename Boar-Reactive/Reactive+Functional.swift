//
//  Reactive.swift
//  Boar-Reactive
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond

public extension SignalProtocol where Element == Void {
    public func with<U: AnyObject>(weak left: U) -> Signal<U> {
        weak var weak: U? = left
        
        return Signal { observer in
            return self.observe { event in
                switch event {
                    
                case .next(_):
                    if let strong = weak {
                        observer.next ( strong)
                    }
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
    
    public func with<U>(left: U) -> Signal<U> {
        
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(_):
                    observer.next ( (left) )
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
}


public extension SignalProtocol {
    public func once()->Signal<Element> {
        var happened = false
        return Signal { observer in
            return self.observe { event in
                switch event {
                    
                case .next(let element):
                    if !happened {
                        happened = true
                        observer.next (element)
                    }
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
    public func with<U: AnyObject>(weak left: U) -> Signal<(Element, U)> {
        weak var weak: U? = left
        
        return Signal { observer in
            return self.observe { event in
                switch event {
                    
                case .next(let element):
                    if let strong = weak {
                        observer.next ( (element, strong) )
                    }
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
    
    public func with<U>(val: U) -> Signal<(Element, U)> {
        
        return Signal { observer in
            return self.observe { event in
                switch event {
                case .next(let element):
                    observer.next ( (element, val) )
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
    
    func doOnNext(_ next: @escaping (Element)->Void)->Signal<Element>{
        return doOn(next: next)
    }
    //@discardableResult
}

public extension Future {
    public func on(_ context: @escaping ExecutionContext) -> Future<T> {
        return map(context) { $0 }
    }
    var val: Property<T?> {
        let prop = Property<T?>(nil)
        self.onSuccess(callback: prop.next)
        return prop
    }
    
    var sig: Signal<T> {
        return Signal { observer in
            self.onSuccess(callback: observer.completed)
            self.onFailure(callback: observer.failed)
            return observer.disposable
        }
    }
}

public extension Future {
    func with<U: AnyObject>(weak obj: U) -> Future<(T,U)> {
        let res = Promise<(T, U)>()
        weak var weak: U? = obj
        self.onComplete(callback: { (result: Value) in
            result.analysis(
                ifSuccess: {
                    if let strong = weak {
                        res.success( ($0, strong) )
                    }
            },
                ifFailure: { res.failure($0) })
        })
        return res.future
    }
    
    func with<U>(obj: U) -> Future<(T,U)> {
        let res = Promise<(T, U)>()
        
        self.onComplete(callback: { (result: Value) in
            result.analysis(
                ifSuccess: { res.success( ($0, obj) ) },
                ifFailure:  res.failure)
        })
        return res.future
        
    }
    
}

public extension Future where T == Void {
    func with<U: AnyObject>(weak obj: U) -> Future<U> {
        let res = Promise<U>()
        weak var weak: U? = obj
        self.onComplete(callback: { (result: Value) in
            result.analysis(
                ifSuccess: {
                    if let strong = weak {
                        res.success( (strong) )
                    }
            },
                ifFailure: res.failure )
        })
        return res.future
    }
    
    func with<U>(obj: U) -> Future<U> {
        let res = Promise<U>()
        self.onComplete(callback: { (result: Value) in
            result.analysis(
                ifSuccess: { res.success( obj ) },
                ifFailure: res.failure)
        })
        return res.future
    }
}

//extension Error {
//    public static let wrongFilterCode = 80001
//    public static let wrongFilter = Error.Err(Error.wrongFilterCode, userInfo: ["Message" : "Filter didn't pass the conditions"])
//}
//
//
//public extension Future where E == NSError {
//    public func filter(_ p: @escaping (Value.Value) -> Bool) -> Future<Value.Value, NSError> {
//        return flatMap(ImmediateExecutionContext) { value -> Future<Value.Value, NSError> in
//            if p(value) {
//                return Future(value: value)
//            } else {
//                return Future(error: Error.wrongFilter)
//            }
//        }
//    }
//    
//    
//}



public extension SignalProtocol where Element : OptionalProtocol {
    
    func recoverNil(_ def: @autoclosure @escaping ()->Element.Wrapped)-> Signal<Element.Wrapped> {
        return self.map{ $0._unbox ?? def() }
    }
}

public extension SignalProtocol {
    
    public func flatMap<U>(_ transform: @escaping (Element) -> Future<U>) -> Signal<U> {
        return Signal { observer in
            var token = InvalidationToken()
            return self.observe { event in
                switch event {
                case .next(let element):
                    token.invalidate()
                    token = InvalidationToken()
                    transform(element).on(token.validContext)
                        .onSuccess(callback: observer.next)
                        .onFailure(callback: observer.failed)
                    
                case .failed(_): break
                case .completed:
                    observer.completed()
                }
            }
        }
    }
}
public extension DispatchQueue{
    
    static func delay(_ delay: DispatchTimeInterval)->Future<Void>{
        return Future<Void>(value: (), delay: delay)
    }
}

public extension Promise {
    func materialize(from f: (() throws -> T) ){
        do {
            success(try f())
        }catch {
            failure(error)
        }
    }
}

extension SignalProtocol where Element: ObservableArrayEventProtocol {
    func array() -> Signal<[Element.Item]> {
        return Signal{observer in
            var isBatch = false
            return self.observe{event in
                switch event {
                case .next(let change):
                    switch change.change {
                    case .beginBatchEditing: isBatch = true
                    case .endBatchEditing: isBatch = false
                    default: break
                    }
                    if !isBatch {
                        observer.next(change.source)
                    }
                case .failed(let error):
                    observer.failed(error)
                case .completed:
                    observer.completed()
                }
            }
        }
    }
    func count()->SafeSignal<Int>{
        return self.array().map { $0.count }.suppressError(logging: false)
    }
}

