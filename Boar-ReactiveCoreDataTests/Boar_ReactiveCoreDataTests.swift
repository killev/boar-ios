//
//  Boar_ReactiveCoreDataTests.swift
//  Boar-ReactiveCoreDataTests
//
//  Created by Peter Ovchinnikov on 1/19/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import XCTest
import Boar_ReactiveCoreData

public extension UIApplication {
    public static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    public static let libraryDirectory: URL = {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    public static let temporaryDirectory: URL = {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }()
    
    public static let cacheDirectory: URL = {
        return libraryDirectory.appendingPathComponent("Caches", isDirectory: true).appendingPathComponent("com.coolcousin.cache", isDirectory: true)
    }()
}


class Boar_ReactiveCoreDataTests: XCTestCase {
    
    var context: CDContext!
    override func setUp() {
        super.setUp()
        let bundle    = Bundle(for: Boar_ReactiveCoreDataTests.self)
        let modelURL  = bundle.url(forResource: "tests", withExtension: "momd")!
        let sqliteURL: URL = UIApplication.documentsDirectory.appendingPathComponent("Testl-\(UUID().uuidString).sqlite")
        try? FileManager.default.removeItem(at: sqliteURL)
        context = try! CDContext(modelURL, sqliteURL: sqliteURL)
    }
    
    override func tearDown() {
        context.remove()
        super.tearDown()
    }
    
    private func create(){
        let add = context.perform {cxt in
            return [self.context.create(TestEntity.self) {
                $0.id = UUID()
                $0.url = ""
                }
            ]
        }
        XCTAssertFutureSuccess("Shoul add 1 element", future: add)
    }
    
    func testCreate() {
        
        create()
        XCTAssertFutureSuccess("Should have 1 element", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(1, res.count)
        }
    }
    
    func testCreateFail() {
        
        let future = context.perform {cxt in
            return [self.context.create(TestEntity.self) {_ in
                throw NSError(domain: "dom", code: 123, userInfo: nil)
                }
            ]
        }
        XCTAssertFutureFailure("Shouldn't add any elements", future: future)
        
        XCTAssertFutureSuccess("Shouldn't have any elements", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(0, res.count)
        }
    }
    
    func testUpdate() {
        
        create()
        let newUrl = "bla-bla"
        
        let update = context.findAll(TestEntity.self)
            .flatMap{ res in
                self.context.perform {
                    [$0.update(TestEntity.self, obj: res.first!){$0.url = newUrl}]
                }
        }
        
        XCTAssertFutureSuccess("Should update 1 element", future: update){ res in
            XCTAssertEqual(1, res.updated.count)
        }
        XCTAssertFutureSuccess("Shouldn't have any elements", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(1, res.count)
            XCTAssertEqual(newUrl, res.first!.url)
        }
    }
    
    func testBatchUpdate() {
        
        create()
        let newUrl = "bla-bla"
        

        let update = context.perform {
            [$0.update(TestEntity.self, pred: NSPredicate(value: true) ){$0.url = newUrl}]
        }
        
        XCTAssertFutureSuccess("Should update 1 element", future: update){ res in
            XCTAssertEqual(1, res.updated.count)
        }
        XCTAssertFutureSuccess("Shouldn't have any elements", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(1, res.count)
            XCTAssertEqual(newUrl, res.first!.url)
        }
    }
    
}
