//
//  File.swift
//  Boar-ReactiveCoreDataTests
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Boar_ReactiveCoreData
import XCTest
import Bond

class CDContextFetchTests: XCTestCase {
    
    var context: CDContext!
    override func setUp() {
        super.setUp()
        let bundle    = Bundle(for: CDContextFetchTests.self)
        let modelURL  = bundle.url(forResource: "tests", withExtension: "momd")!
        let sqliteURL: URL = UIApplication.documentsDirectory.appendingPathComponent("Testl-\(UUID().uuidString).sqlite")
        try? FileManager.default.removeItem(at: sqliteURL)
        context = try! CDContext(modelURL, sqliteURL: sqliteURL)
    }
    
    override func tearDown() {
        context.remove()
        reactive.bag.dispose()
        super.tearDown()
    }
    
    private func create(){
        print("starting adding")
        let add = context.perform {
            return [CDContext.create(TestEntity.self) {
                $0.id = UUID()
                $0.url = ""
                }
            ]
        }
        XCTAssertFutureSuccess("Should add 1 element", future: add)
    }
    
  
    
    func testFetch() {
        let expectation = self.expectation(description: "testFetch - Expectation")
        create()
        let obs = context.fetch(TestEntity.self, initial: NSPredicate(value: true), order: [("id", true)])
        var p:Int = 0
        obs.observeNext{ event in
            p += 1
            if p == 5{
               expectation.fulfill()
            }
        }.dispose(in: reactive.bag)
        
        
        
        let arr = Observable2DArray<String, TestEntity>()
            
        
        arr.bind(to: <#T##UICollectionView#>, createCell: <#T##CollectionViewBond#>)
 
        create()
        let newUrl = "bla-bla"
        
        
        let update = context.perform {
            [CDContext.update(TestEntity.self, pred: NSPredicate(value: true) ){$0.url = newUrl}]
        }
        XCTAssertFutureSuccess("Should update 2 element", future: update)
        waitForExpectations(timeout: 30, handler: nil)
    }
}
