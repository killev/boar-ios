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
        return libraryDirectory.appendingPathComponent("Caches", isDirectory: true).appendingPathComponent("com.boar.cache", isDirectory: true)
    }()
}


class DBContextCoreDataTests: XCTestCase {
    
    var context: DBContext!
    override func setUp() {
        super.setUp()
        let bundle    = Bundle(for: DBContextCoreDataTests.self)
        let modelURL  = bundle.url(forResource: "tests", withExtension: "momd")!
        let sqliteURL: URL = UIApplication.documentsDirectory.appendingPathComponent("Testl-\(UUID().uuidString).sqlite")
        try? FileManager.default.removeItem(at: sqliteURL)
        
        context = try! DBContext(modelURL, sqliteURL: sqliteURL)
    }
    
    override func tearDown() {
        context.delete()
        super.tearDown()
    }
    
    private func create() {
        
        let operation = DBContext.create(TestEntity.self) {
            $0.patch(with: ["id": UUID(), "url": ""])
        }
        
        let add = context.perform {
            return [
                operation
            ]
        }
        XCTAssertFutureSuccess("Should add 1 element", future: add)
    }
    
    func testCreate() {
        
        create()
        
        XCTAssertFutureSuccess("Should have 1 element", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(1, res.count)
        }
    }
    
    func testCreateFail() {

        let future = context.perform {
            return [DBContext.create(TestEntity.self) {_ in
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
                return self.context.perform {
                    [
                        DBContext.update(TestEntity.self, obj: res.first!){ $0.patch(with: ["url": newUrl])}
                    ]
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
            [DBContext.update(TestEntity.self, pred: NSPredicate(value: true) ){ $0.patch(with: ["url": newUrl])}]
        }

        XCTAssertFutureSuccess("Should update 1 element", future: update){ res in
            XCTAssertEqual(1, res.updated.count)
        }
        XCTAssertFutureSuccess("Shouldn't have any elements", future: context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(1, res.count)
            XCTAssertEqual(newUrl, res.first!.url)
        }
    }
    
    func testDelete() {

        create()
        let futureAllEntity = context.findAll(TestEntity.self)

        let delete = futureAllEntity
            .flatMap { res in
                return self.context.perform {
                    [DBContext.delete(TestEntity.self, obj: res.first!)]
                }
        }
        
        self.XCTAssertFutureSuccess("Should delete 1 element", future: delete){ res in
            XCTAssertEqual(1, res.deleted.count)
        }
        self.XCTAssertFutureSuccess("Shouldn't have any elements", future: self.context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(0, res.count)
        }
    }
    
    func testDeleteWithPred() {
        
        create()
        
        let delete = self.context.perform {
            return [DBContext.delete(TestEntity.self, pred: NSPredicate(value: true))]
        }
        
        self.XCTAssertFutureSuccess("Should delete 1 element", future: delete){ res in
            XCTAssertEqual(1, res.deleted.count)
        }
        self.XCTAssertFutureSuccess("Shouldn't have any elements", future: self.context.findAll(TestEntity.self)){ res in
            XCTAssertEqual(0, res.count)
        }
    }
    
}
