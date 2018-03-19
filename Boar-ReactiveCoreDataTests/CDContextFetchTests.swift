//
//  File.swift
//  Boar-ReactiveCoreDataTests
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_Reactive
import Boar_ReactiveCoreData
import XCTest

class CDContextFetchTests: XCTestCase {
//    
//    var context: CDContext!
//    override func setUp() {
//        super.setUp()
//        let bundle    = Bundle(for: CDContextFetchTests.self)
//        let modelURL  = bundle.url(forResource: "tests", withExtension: "momd")!
//        let sqliteURL: URL = UIApplication.documentsDirectory.appendingPathComponent("Testl-\(UUID().uuidString).sqlite")
//        try? FileManager.default.removeItem(at: sqliteURL)
//        context = try! CDContext(modelURL, sqliteURL: sqliteURL)
//    }
//    
//    override func tearDown() {
//        context.remove()
//        reactive.bag.dispose()
//        super.tearDown()
//    }
//    
//    private func create() {
//        let add = context.perform {
//            return [CDContext.create(TestEntity.self) {
//                $0.id = UUID()
//                $0.url = UUID().uuidString
//            }
//            ]
//        }
//        XCTAssertFutureSuccess("Should add 1 element", future: add)
//    }
//    
    func testFetch() {
//        let expectation = self.expectation(description: "testFetch - Expectation")
//        create()
//
//        let observable = context.fetch(TestEntity.self, initial: NSPredicate(value: true), order: [("url", true)])
//
//        var count = 0
//        observable.observeIn(.immediateOnMain).observeNext{ event in
//            count += 1
//            print(event.change, event.source.count, Thread.isMainThread, count)
//            Thread.sleep(forTimeInterval: 0.01)
//            if count == 71 {
//                expectation.fulfill()
//            }
//
//        }.dispose(in: reactive.bag)
        
//        let collectionView = UICollectionView()
        
        //observable.bind(to: collectionView, using: <#T##TableViewBond#>)
        
//        for _ in 0...10{
//            create()
//        }
//        
//        let batchAdd = context.perform{
//            (0..<10).map{_ in CDContext.create(TestEntity.self){
//                $0.id = UUID()
//                $0.url = UUID().uuidString
//                }
//            }
//        }
//        XCTAssertFutureSuccess("Should add 10 element", future: batchAdd)
//
        
//        let update = context.perform {
//            [CDContext.update(TestEntity.self, pred: NSPredicate(value: true) ){ $0.url = UUID().uuidString} ]
//        }
//        XCTAssertFutureSuccess("Should update 10 element", future: update)
//        waitForExpectations(timeout: 30, handler: nil)
//        XCTAssertEqual(71, count)
    }

    func testObservableAsync() {
        let async = self.expectation(description: "async")
        
        let array = MutableObservableArray<Int>([])
        var expected:[Int] = []
    
        let disposable = array.observeIn(.immediateOnMain).observeNext{ event in
            XCTAssertEqual(expected, event.dataSource)
            expected.append(expected.count)
            Thread.sleep(forTimeInterval: 0.01)
            if expected.count == 10 {
                async.fulfill()
            }
        }
        
        DispatchQueue.global().async {
            for i in 0..<10 {
                array.append(i)
            }
        }
        wait(for: [async], timeout: 1)
        disposable.dispose()
    }
}

