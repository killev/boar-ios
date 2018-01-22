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




//this hack fixes compilation crash
fileprivate func createFR<T:NSManagedObject>(context: NSManagedObjectContext, predicate: NSPredicate, order: [(String,Bool)])->NSFetchedResultsController<T> {
    
    //NSAsynchronousFetchRequest
    let request = NSFetchRequest<T>(entityName: T.entity().name!)
    request.predicate = predicate
    
    var sortDesriptors = [NSSortDescriptor]()
    for (sortTerm, ascending) in order {
        sortDesriptors.append(NSSortDescriptor(key: sortTerm, ascending: ascending))
    }
    request.sortDescriptors = sortDesriptors
    
    return NSFetchedResultsController<T>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
}

public class CDFetchedObservable <Item: NSManagedObject> : ObservableArrayBase<Item>  {
    
    override public var array: [Item] {
        return fetched.fetchedObjects ?? []
    }
    private let queue = DispatchQueue(label: "com.boar.core-data-fetched-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    private var context : NSManagedObjectContext!
    
    private var delegate: DelegateImpl!
    private var fetched: NSFetchedResultsController<Item>!
    
    init(parent: NSManagedObjectContext, initial: NSPredicate = NSPredicate(value: false), order: [(String,Bool)]) {
        super.init()
        delegate = DelegateImpl(subject: subject, source: self)
        queue.sync {
            self.context = NSManagedObjectContext(parent: parent, merge: true)

            fetched = createFR(context: self.context, predicate: initial, order: order)
            fetched.delegate = delegate
        }
        
        _ = self.context.async{ _ in
            try self.fetched.performFetch()
            }.onSuccess {_ in
                self.subject.next(ObservableArrayEvent(change: .reset, source: self.array))
            }
    }
    
    deinit {
        print("deinit", type(of: self))
    }

}
extension CDFetchedObservable {
    
    class BatchUpdater {
        
        var changes: [ObservableArrayChange] = []
        
        init(){
            
        }
        func add(change: ObservableArrayChange) {
            changes.append(change)
        }
        func populate(to subject: PublishSubject<ObservableArrayEvent<Item>, NoError>, with source: CDFetchedObservable) {
            
            if changes.count > 40 {
                subject.next(ObservableArrayEvent(change: .reset, source: source.array))
            } else if changes.count > 0 {
                // ...otherwise batch:
                subject.next(ObservableArrayEvent(change: .beginBatchEditing, source: source.array))
                changes.forEach { change in
                    subject.next(ObservableArrayEvent(change: change, source: source.array))
                }
                subject.next(ObservableArrayEvent(change: .endBatchEditing, source: source.array))
            }
            
        }
    }
    
    class DelegateImpl : NSObject, NSFetchedResultsControllerDelegate {
        weak var subject: PublishSubject<ObservableArrayEvent<Item>, NoError>?
        weak var source: CDFetchedObservable?
        
        
        init(subject: PublishSubject<ObservableArrayEvent<Item>, NoError>, source : CDFetchedObservable) {
            self.subject = subject
            self.source = source
        }
        //
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch type {
                
            case .insert:
                batchUpdater?.add(change: .inserts([newIndexPath!.row]))
            case .delete:
                batchUpdater?.add(change: .deletes([indexPath!.row]))
            case .move:
                batchUpdater?.add(change: .move(indexPath!.row, newIndexPath!.row))
            case .update:
                batchUpdater?.add(change: .updates([indexPath!.row]))
            }
        }
        var batchUpdater: BatchUpdater?
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            batchUpdater = BatchUpdater()
        }
        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            guard let subject = subject, let source = source else {
                return
            }
            batchUpdater?.populate(to: subject, with: source)
            batchUpdater = nil
        }
        public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType){
            
            print("didChange section")
        }
        deinit {
            print("deinit - ", type(of:self))
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


