//
//  File.swift
//  Boar-ReactiveNetworkingTests
//
//  Created by Peter Ovchinnikov on 1/15/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//
import XCTest
import Alamofire
import ObjectMapper
import Boar_ReactiveNetworking
import BrightFutures


protocol Patchable {
    func patch(with: Dictionary<String, Any>) -> Self
}

struct G_H_Issue : ImmutableMappable {
    init(map: Map) throws {
        url = try map.value("url")
    }
    
    func mapping(map: Map) {
        url >>> map["url"]
    }
    let url: String
}


class AlamofireFuturesTests: XCTestCase {
    
    func testSimple(){
        let issues = Alamofire
            .request("https://api.github.com/repos/killev/boar-ios/issues",
                     method: .get,
                     parameters: [:],
                     encoding: URLEncoding.default,
                     headers: Auth.basic1(user: "killev", password: "CrossPlusPlus50000"))
            .responseArray(G_H_Issue.self)
        
        XCTAssertFutureSuccess("testSimple", future: issues){ res in
            XCTAssertEqual(1, res.count)
        }
    }
}
