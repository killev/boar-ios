//
//  Async+ResultType.swift
//  BrightFutures
//
//  Created by Thomas Visser on 10/07/15.
//  Copyright © 2015 Thomas Visser. All rights reserved.
//

public extension AsyncType where Value: ResultProtocol {
    /// `true` if the future completed with success, or `false` otherwise
    public var isSuccess: Bool {
        return result?.analysis(ifSuccess: { _ in return true }, ifFailure: { _ in return false }) ?? false
    }
    
    /// `true` if the future failed, or `false` otherwise
    public var isFailure: Bool {
        return result?.analysis(ifSuccess: { _ in return false }, ifFailure: { _ in return true }) ?? false
    }
    
    public var value: Value.Value? {
        return result?.value
    }
    
    public var error: Error? {
        return result?.error
    }
    
    /// Adds the given closure as a callback for when the future succeeds. The closure is executed on the given context.
    /// If no context is given, the behavior is defined by the default threading model (see README.md)
    /// Returns self
    @discardableResult
    public func onSuccess(_ context: ExecutionContext = .defaultContext, callback: @escaping (Value.Value) -> Void) -> Self {
        self.onComplete(context) { result in
            result.analysis(ifSuccess: callback, ifFailure: { _ in })
        }
        
        return self
    }
    
    /// Adds the given closure as a callback for when the future fails. The closure is executed on the given context.
    /// If no context is given, the behavior is defined by the default threading model (see README.md)
    /// Returns self
    @discardableResult
    public func onFailure(_ context: ExecutionContext = .defaultContext, callback: @escaping (Error) -> Void) -> Self {
        self.onComplete(context) { result in
            result.analysis(ifSuccess: { _ in }, ifFailure: callback)
        }
        return self
    }
    
    /// Enables the the chaining of two future-wrapped asynchronous operations where the second operation depends on the success value of the first.
    /// Like map, the given closure (that returns the second operation) is only executed if the first operation (this future) is successful.
    /// If a regular `map` was used, the result would be a `Future<Future<U>>`. The implementation of this function uses `map`, but then flattens the result
    /// before returning it.
    ///
    /// If this future fails, the returned future will fail with the same error.
    /// If this future succeeds, the returned future will complete with the future returned from the given closure.
    ///
    /// The closure is executed on the given context. If no context is given, the behavior is defined by the default threading model (see README.md)
    public func flatMap<U>(_ context: ExecutionContext, f: @escaping (Value.Value) -> Future<U>) -> Future<U> {
        return map(context, f: f).flatten()
    }
    
    /// See `flatMap<U>(context c: ExecutionContext, f: T -> Future<U, E>) -> Future<U, E>`
    /// The given closure is executed according to the default threading model (see README.md)
    public func flatMap<U>(_ f: @escaping (Value.Value) -> Future<U>) -> Future<U> {
        return flatMap(.defaultContext, f: f)
    }
    
    /// Transforms the given closure returning `Result<U>` to a closure returning `Future<U>` and then calls
    /// `flatMap<U>(context c: ExecutionContext, f: T -> Future<U>) -> Future<U>`
    public func flatMap<U>(_ context: ExecutionContext, f: @escaping (Value.Value) -> Result<U>) -> Future<U> {
        return self.flatMap(context) { value in
            return Future<U>(result: f(value))
        }
    }
    
    /// See `flatMap<U>(context c: ExecutionContext, f: T -> Result<U, E>) -> Future<U, E>`
    /// The given closure is executed according to the default threading model (see README.md)


        public func flatMap<U>(_ f: @escaping (Value.Value) -> Result<U>) -> Future<U> {
        return flatMap(.defaultContext, f: f)
    }
    
    /// See `map<U>(context c: ExecutionContext, f: (T) -> U) -> Future<U>`
    /// The given closure is executed according to the default threading model (see README.md)
    public func map<U>(_ f: @escaping (Value.Value) -> U) -> Future<U> {
        return self.map(.defaultContext, f: f)
    }
    
    /// Returns a future that succeeds with the value returned from the given closure when it is invoked with the success value
    /// from this future. If this future fails, the returned future fails with the same error.
    /// The closure is executed on the given context. If no context is given, the behavior is defined by the default threading model (see README.md)
    public func map<U>(_ context: ExecutionContext, f: @escaping (Value.Value) -> U) -> Future<U> {
        let res = Future<U>()
        
        self.onComplete(context, callback: { (result: Value) in
            result.analysis(
                ifSuccess: { res.success(f($0)) },
                ifFailure: { res.failure($0) })
        })
        
        return res
    }
    
    /// Returns a future that completes with this future if this future succeeds or with the value returned from the given closure
    /// when it is invoked with the error that this future failed with.
    /// The closure is executed on the given context. If no context is given, the behavior is defined by the default threading model (see README.md)
    public func recover(context c: ExecutionContext = .defaultContext, task: @escaping (Error) -> Value.Value) -> Future<Value.Value> {
        return self.recoverWith(context: c) { error -> Future<Value.Value> in
            return Future<Value.Value>(value: task(error))
        }
    }
    
    /// Returns a future that completes with this future if this future succeeds or with the value returned from the given closure
    /// when it is invoked with the error that this future failed with.
    /// This function should be used in cases where there are two asynchronous operations where the second operation (returned from the given closure)
    /// should only be executed if the first (this future) fails.
    /// The closure is executed on the given context. If no context is given, the behavior is defined by the default threading model (see README.md)
    public func recoverWith(context c: ExecutionContext = .defaultContext, task: @escaping (Error) -> Future<Value.Value>) -> Future<Value.Value> {
        let res = Future<Value.Value>()
        
        self.onComplete(c) { result in
            result.analysis(
                ifSuccess: { res.success($0) },
                ifFailure: { res.completeWith(task($0)) })
        }
        
        return res
    }
    
    /// See `mapError<E1>(context c: ExecutionContext, f: E -> E1) -> Future<T, E1>`
    /// The given closure is executed according to the default threading model (see README.md)
    public func mapError<E1: Error>(_ f: @escaping (Error) -> E1) -> Future<Value.Value> {
        return mapError(.defaultContext, f: f)
    }
    
    /// Returns a future that fails with the error returned from the given closure when it is invoked with the error
    /// from this future. If this future succeeds, the returned future succeeds with the same value and the closure is not executed.
    /// The closure is executed on the given context.
    public func mapError<E1: Error>(_ context: ExecutionContext, f: @escaping (Error) -> E1) -> Future<Value.Value> {
        let res = Future<Value.Value>()

        self.onComplete(context) { result in
            result.analysis(
                ifSuccess: { res.success($0) } ,
                ifFailure: { res.failure(f($0)) })
        }

        return res
    }
    
    /// Returns a future that succeeds with a tuple consisting of the success value of this future and the success value of the given future
    /// If either of the two futures fail, the returned future fails with the failure of this future or that future (in this order)
    public func zip<U>(_ that: Future<U>) -> Future<(Value.Value,U)> {
        return flatMap(.immediate) { thisVal -> Future<(Value.Value,U)> in
            return that.map(.immediate) { thatVal in
                return (thisVal, thatVal)
            }
        }
    }
    
    /// Returns a future that succeeds with the value that this future succeeds with if it passes the test
    /// (i.e. the given closure returns `true` when invoked with the success value) or an error with code
    /// `ErrorCode.noSuchElement` if the test failed.
    /// If this future fails, the returned future fails with the same error.
    public func filter(_ p: @escaping (Value.Value) -> Bool) -> Future<Value.Value> {
        return self.mapError(.immediate) { error in
            return BrightFuturesError(external: error)
        }.flatMap(.immediate) { value -> Result<Value.Value> in
            if p(value) {
                return Result(value: value)
            } else {
                return Result(error: BrightFuturesError.noSuchElement)
            }
        }
    }
    
    /// Returns a new future with the new type.
    /// The value or error will be casted using `as!` and may cause a runtime error
    public func forceType<U>() -> Future<U> {
        return self.map(.immediate) {
            $0 as! U
        }
    }
    
    /// Returns a new future that completes with this future, but returns Void on success
    public func asVoid() -> Future<Void> {
        return self.map(.immediate) { _ in return () }
    }
}

public extension AsyncType where Value: ResultProtocol, Value.Value: AsyncType, Value.Value.Value: ResultProtocol {
    /// Returns a future that fails with the error from the outer or inner future or succeeds with the value from the inner future
    /// if both futures succeed.
    public func flatten() -> Future<Value.Value.Value.Value> {
        let f = Future<Value.Value.Value.Value>()
        
        onComplete(.immediate) { res in
            res.analysis(ifSuccess: { innerFuture -> () in
                innerFuture.onComplete(.immediate) { (res:Value.Value.Value) in
                    res.analysis(ifSuccess: { f.success($0) }, ifFailure: { err in f.failure(err) })
                }
            }, ifFailure: { f.failure($0) })
        }
        
        return f
    }
    
}

