//
//  Alamofire+REST.swift
//  Boar-ReactiveNetworking
//
//  Created by Peter Ovchinnikov on 1/15/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import BrightFutures
import Alamofire
import ObjectMapper
import AlamofireObjectMapper


extension Promise {
    func tryComplete(_ result:Alamofire.Result<T>) {
        switch result {
        case .success(let data): trySuccess(data)
        case .failure(let error): tryFailure(error as! E)
        }
    }
}

public extension DataRequest {
    
    
    func responseObject<T: ImmutableMappable>(_ type: T.Type, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Future<T, NSError> {
        
        let promise = Promise<T, NSError>()
        let obj: T? = nil
        responseObject(queue: queue, keyPath: keyPath, mapToObject: obj, context: context) { response in
            if response.result.isFailure {
                // @TODO
                print(String(data: response.data!, encoding: .utf8) ?? "Unknown error")
            }
            promise.tryComplete(response.result)
        }
        
        return promise.future
    }
    
    
//    public func responseArray<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, completionHandler: DataResponse<[T]> -> Void) -> Self

    
    func responseArray<T: ImmutableMappable>(_ type: T.Type, queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil) -> Future<Array<T>, NSError> {
        
        let promise = Promise<[T], NSError>()
        
        self.responseArray(queue: queue, keyPath: keyPath, context: context) { (response: DataResponse<[T]>) -> Void in
            promise.tryComplete(response.result)
        }
        
        return promise.future
    }
    
    
    public func responseJSON(queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments) -> Future<Any, NSError>{
        
        
        let promise = Promise<Any, NSError>()
        
        responseJSON(queue: queue, options: options) { response in
            if response.result.isFailure {
                // @TODO
                print(String(data: response.data!, encoding: .utf8) ?? "Unknown error")
            }
            promise.tryComplete(response.result)
        }
        
        return promise.future
        
    }
}

