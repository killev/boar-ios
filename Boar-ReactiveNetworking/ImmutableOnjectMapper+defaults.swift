//
//  ImmutableOnjectMapper+defaults.swift
//  Boar-ReactiveNetworking
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import ObjectMapper


//public extension Map {
//    
//    /// Returns a value or default.
//    public func value<T>(_ key: String, nested: Bool? = nil, delimiter: String = ".", `default`: T) -> T {
//        return (try? value(key, nested: nested, delimiter: delimiter)) ?? `default`
//    }
//    
//    /// Returns a transformed value or default.
//    
//    public func value<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform, `default`: Transform.Object)  -> Transform.Object {
//        return (try? value(key, nested: nested, delimiter: delimiter, using: transform)) ?? `default`
//    }
//  
//    
//    /// Returns a RawRepresentable type or defaulr.
//    public func value<T: RawRepresentable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", `default`: T)  -> T {
//        return (try? value(key, nested: nested, delimiter: delimiter, using: EnumTransform()) ??`default`
//    }
//    
//    /// Returns a `[RawRepresentable]` type or throws an error.
//    public func value<T: RawRepresentable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", `default`: [T]) -> [T] {
//        return self.value(key, nested: nested, delimiter: delimiter, using: EnumTransform(), default: `default`)
//    }
//    
//    // MARK: BaseMappable
//    
//    /// Returns a `BaseMappable` object or throws an error.
//    public func value<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", `default`: T) -> T {
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let JSONObject = currentValue else {
//            return `default`
//        }
//        return try Mapper<T>(context: context).mapOrFail(JSONObject: JSONObject)
//    }
//    
//    // MARK: [BaseMappable]
//    
//    /// Returns a `[BaseMappable]` or throws an error.
//    public func value<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [T] {
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let jsonArray = currentValue as? [Any] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[Any]'", file: file, function: function, line: line)
//        }
//        
//        return try jsonArray.map { JSONObject -> T in
//            return try Mapper<T>(context: context).mapOrFail(JSONObject: JSONObject)
//        }
//    }
//    
//    /// Returns a `[BaseMappable]` using transform or throws an error.
//    public func value<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [Transform.Object] {
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let jsonArray = currentValue as? [Any] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[Any]'", file: file, function: function, line: line)
//        }
//        
//        return try jsonArray.map { json -> Transform.Object in
//            guard let object = transform.transformFromJSON(json) else {
//                throw MapError(key: "\(key)", currentValue: json, reason: "Cannot transform to '\(Transform.Object.self)' using \(transform)", file: file, function: function, line: line)
//            }
//            return object
//        }
//    }
//    
//    // MARK: [String: BaseMappable]
//    
//    /// Returns a `[String: BaseMappable]` or throws an error.
//    public func value<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [String: T] {
//        
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let jsonDictionary = currentValue as? [String: Any] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[String: Any]'", file: file, function: function, line: line)
//        }
//        var value: [String: T] = [:]
//        for (key, json) in jsonDictionary {
//            value[key] = try Mapper<T>(context: context).mapOrFail(JSONObject: json)
//        }
//        return value
//    }
//    
//    /// Returns a `[String: BaseMappable]` using transform or throws an error.
//    public func value<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [String: Transform.Object] {
//        
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let jsonDictionary = currentValue as? [String: Any] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[String: Any]'", file: file, function: function, line: line)
//        }
//        var value: [String: Transform.Object] = [:]
//        for (key, json) in jsonDictionary {
//            guard let object = transform.transformFromJSON(json) else {
//                throw MapError(key: key, currentValue: json, reason: "Cannot transform to '\(Transform.Object.self)' using \(transform)", file: file, function: function, line: line)
//            }
//            value[key] = object
//        }
//        return value
//    }
//    
//    // MARK: [[BaseMappable]]
//    /// Returns a `[[BaseMappable]]` or throws an error.
//    public func value<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".", file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [[T]] {
//        
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let json2DArray = currentValue as? [[Any]] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[[Any]]'", file: file, function: function, line: line)
//        }
//        return try json2DArray.map { jsonArray in
//            try jsonArray.map { jsonObject -> T in
//                return try Mapper<T>(context: context).mapOrFail(JSONObject: jsonObject)
//            }
//        }
//    }
//    
//    /// Returns a `[[BaseMappable]]` using transform or throws an error.
//    public func value<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws -> [[Transform.Object]] {
//        
//        let currentValue = self.currentValue(for: key, nested: nested, delimiter: delimiter)
//        guard let json2DArray = currentValue as? [[Any]] else {
//            throw MapError(key: key, currentValue: currentValue, reason: "Cannot cast to '[[Any]]'",
//                           file: file, function: function, line: line)
//        }
//        
//        return try json2DArray.map { jsonArray in
//            try jsonArray.map { json -> Transform.Object in
//                guard let object = transform.transformFromJSON(json) else {
//                    throw MapError(key: "\(key)", currentValue: json, reason: "Cannot transform to '\(Transform.Object.self)' using \(transform)", file: file, function: function, line: line)
//                }
//                return object
//            }
//        }
//    }
//}

