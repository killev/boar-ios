//
//  CoreDataFetchedResult.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import CoreData


public protocol CDFetchedEventProtocol {
    associatedtype SectionMetadata
    associatedtype Item: NSManagedObject
    var change: Observable2DArrayChange { get }
    var source: CDFetched<SectionMetadata, Item> { get }
}


public struct CDFetchedEvent<SectionMetadata, Item: NSManagedObject>: CDFetchedEventProtocol {
    public let change: Observable2DArrayChange
    public let source: CDFetched<SectionMetadata, Item>
    
    public init(change: Observable2DArrayChange, source: CDFetched<SectionMetadata, Item>) {
        self.change = change
        self.source = source
    }
    
//    public init(change: Observable2DArrayChange, source: [Observable2DArraySection<SectionMetadata, Item>]) {
//        self.change = change
//        self.source = CDFetched(source)
//    }
}

//public struct CDFetchedPatchEvent<SectionMetadata, Item>: Observable2DArrayEventProtocol {
//    public let change: Observable2DArrayChange
//    public let source: Observable2DArray<SectionMetadata, Item>
//
//    public init(change: Observable2DArrayChange, source: Observable2DArray<SectionMetadata, Item>) {
//        self.change = change
//        self.source = source
//    }
//
//    public init(change: Observable2DArrayChange, source: [Observable2DArraySection<SectionMetadata, Item>]) {
//        self.change = change
//        self.source = Observable2DArray(source)
//    }
//}

//this hack fixes compilation crash
func createFR<T:NSManagedObject>(context: NSManagedObjectContext, predicate: NSPredicate, order: [(String,Bool)])->NSFetchedResultsController<T> {
    
    let request = NSFetchRequest<T>(entityName: T.entity().name!)
    request.predicate = predicate
    
    var sortDesriptors = [NSSortDescriptor]()
    for (sortTerm, ascending) in order {
        sortDesriptors.append(NSSortDescriptor(key: sortTerm, ascending: ascending))
    }
    request.sortDescriptors = sortDesriptors
    
    return NSFetchedResultsController<T>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
}



public class CDFetched <SectionMetadata, Item: NSManagedObject> : SignalProtocol  {

    
    private let queue = DispatchQueue(label: "com.boar.core-data-fetched-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    private var context : NSManagedObjectContext!
//    backgroundQueue.sync {
//    self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//    self.backgroundContext.parent = self.сoordinatorContext
//    self.backgroundContext.automaticallyMergesChangesFromParent = true
//    }
    
    fileprivate let subject = PublishSubject<CDFetchedEvent<SectionMetadata, Item>, NoError>()
    fileprivate let lock = NSRecursiveLock(name: "com.boar.reactivecoredata.fetched")

    private let delegate: DelegateImpl<Item>
    private var fetched: NSFetchedResultsController<Item>!



    init(parent: NSManagedObjectContext, initial: NSPredicate = NSPredicate(value: false), order: [(String,Bool)]) {
        delegate = DelegateImpl()
        queue.sync {
            self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

            self.context.parent = parent
            self.context.automaticallyMergesChangesFromParent = true
           
            fetched = createFR(context: self.context, predicate: initial, order: order)
            fetched.delegate = delegate
        }

        self.context.async{ _ in
            try self.fetched.performFetch()
        }
        
    }
    deinit {
        print("deinit")
    }

   
//    public var numberOfSections: Int {
//        return fetched.num
//    }
//
//    public func numberOfItems(inSection section: Int) -> Int {
//        guard section < numberOfSections else { return 0 }
//        return sections[section].items.count
//    }
    
//    public var startIndex: IndexPath {
//        guard sections.count > 0 else { return IndexPath(item: 0, section: 0) }
//        var section = 0
//        while section < sections.count && sections[section].count == 0 {
//            section += 1
//        }
//        return IndexPath(item: 0, section: section)
//    }
//
//    public var endIndex: IndexPath {
//        return IndexPath(item: 0, section: numberOfSections)
//    }
    
//    public func index(after i: IndexPath) -> IndexPath {
//        if i.section < sections.count {
//            let section = sections[i.section]
//            if i.item + 1 < section.items.count {
//                return IndexPath(item: i.item + 1, section: i.section)
//            } else {
//                var section = i.section + 1
//                while section < sections.count {
//                    if sections[section].items.count > 0 {
//                        return IndexPath(item: 0, section: section)
//                    } else {
//                        section += 1
//                    }
//                }
//                return endIndex
//            }
//        } else {
//            return endIndex
//        }
//    }
    
//    public var isEmpty: Bool {
//        return sections.reduce(true) { $0 && $1.items.isEmpty }
//    }
//
//    public var count: Int {
//        return sections.reduce(0) { $0 + $1.items.count }
//    }
//
//    public subscript(index: IndexPath) -> Item {
//        get {
//            return sections[index.section].items[index.item]
//        }
//    }
    
//    public subscript(index: Int) -> Observable2DArraySection<SectionMetadata, Item> {
//        get {
//            return sections[index]
//        }
//    }
    
    
    public func observe(with observer: @escaping (Event<CDFetchedEvent<SectionMetadata, Item>, NoError>) -> Void) -> Disposable {
        return context.sync{_ in
            observer(.next(CDFetchedEvent(change: .reset, source: self)))
            return self.subject.observe(with: observer)
        }
    }
}
extension NSFetchedResultsChangeType: CustomStringConvertible{
    public var description: String {
        switch self {
        case .delete: return("delete")
        case .insert: return("insert")
        case .move:  return("move")
        case .update: return("update")
        }
    }
}
//extension CDFetched {
    
open class DelegateImpl<Item: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
    override init() {
        
    }
        public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            print("didChange object", type)
            
            //        if (type == .delete) {
            //            indexesToDelete!.append(indexPath!)
            //        } else if (type == .insert){
            //            indexesToInsert!.append(newIndexPath!)
            //        } else if type == .move {
            //            indexesToMove!.append((indexPath!, newIndexPath!))
            //        } else if (type == .update){
            //            indexesToReload!.append(indexPath!)
            //        }
        }
        public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            print("willChange content")
            
            //viewModelCache.removeAll()
            //self.beginChanges()
        }
        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            print("didChange content")
            //self.commitChanges()
        }
        public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType){

            print("didChange section")

            //        if (type == .delete) {
            //            delegate?.deleteSections(self, sections: IndexSet(integer: sectionIndex))
            //        } else if (type == .insert){
            //            delegate?.insertSections(self, sections: IndexSet(integer: sectionIndex))
            //        } else if type == .move {
            //
            //        } else if (type == .update){
            //            delegate?.reloadSections(self, sections: IndexSet(integer: sectionIndex))
            //        }
            //        dataChanged.next(false)
        }
        deinit {
            print("deinit - ", self.description)
        }
    }
//}

