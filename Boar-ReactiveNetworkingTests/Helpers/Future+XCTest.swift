//
//  Future+XCTest.swift
//  Boar-ReactiveNetworkingTests
//
//  Created by Peter Ovchinnikov on 1/15/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import XCTest
import BrightFutures

extension XCTestCase{
    func XCTAssertFutureSuccess<V>(file: StaticString = #file, line: UInt = #line, _ message: String, timeout: TimeInterval = 10, future: @autoclosure () -> Future<V, NSError>, check:((V)->Void)? = nil) {
        
        let token = InvalidationToken()
        
        let expectation = self.expectation(description: message + " - Expectation")
        future().onComplete(token.validContext){result in
            switch result {
            case .success(let value): print (message, " - Success"); check?(value); break
            case .failure(let error): XCTFail(message + " - raises error: " + error.localizedDescription, file: file, line: line)
                
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        token.invalidate()
    }
    
//    func XCTAssertFutureComplete<V>(_ message: String, timeout: TimeInterval, future: Future<V, NSError>, check:((_ value:V)->Void)? = nil) {
//        let token = InvalidationToken()
//        let expectation = self.expectation(description: message + " - Expectation")
//        future.onComplete(token.validContext){result in
//            switch result {
//            case .success(let value): print (message, " - Success");  check?(value); break
//            case .failure(let error): print (message, " - raises error: ", error.localizedDescription)
//
//            }
//            expectation.fulfill()
//
//        }
//        waitForExpectations(timeout: timeout, handler: nil)
//        token.invalidate()
//
//    }
//
//
    func XCTAssertFutureFailure<V>(_ message: String, timeout: TimeInterval = 10, future: Future<V, NSError>){
        let token = InvalidationToken()
        let expectation = self.expectation(description: message + " - Expectation")
        future.onComplete(token.validContext){result in
            switch result {
            case .success(_): XCTFail(message + " - should fail ")
            case .failure(_): print(message + " - fails and that's correct!")

            }
            expectation.fulfill()

        }
        waitForExpectations(timeout: timeout, handler: nil)
        token.invalidate()
    }
    
}
