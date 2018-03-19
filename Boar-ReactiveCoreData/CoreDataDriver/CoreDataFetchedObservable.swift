//
//  CoreDataFetchedResult.swift
//  Boar-ReactiveCoreData
//
//  Created by Peter Ovchinnikov on 1/20/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import CoreData

//this hack fixes compilation crash
fileprivate func createFR<T:NSManagedObject>(context: NSManagedObjectContext, predicate: NSPredicate, order: [(String,Bool)])->NSFetchedResultsController<T> {
    
    //NSAsynchronousFetchRequest
    let request = NSFetchRequest<T>(entityName: T.entityName())
    request.predicate = predicate
    
    var sortDesriptors = [NSSortDescriptor]()
    for (sortTerm, ascending) in order {
        sortDesriptors.append(NSSortDescriptor(key: sortTerm, ascending: ascending))
    }
    request.sortDescriptors = sortDesriptors
    
    return NSFetchedResultsController<T>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
}

public class CoreDataFetchedObservable <Item: NSManagedObject> : ObservableArrayBase<Item>, DisposeBagProvider  {
    
    override public var array: [Item] {
        return fetched.fetchedObjects ?? []
    }
    private let queue = DispatchQueue(label: "com.boar.core-data-fetched-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    private var context : NSManagedObjectContext!
    
    private var delegate: DelegateImpl!
    private var fetched: NSFetchedResultsController<Item>!
    
    
    public let predicate: Property<NSPredicate>
    public let bag = DisposeBag()
    public init(parent: NSManagedObjectContext, initial: NSPredicate = NSPredicate(value: false), order: [(String,Bool)]) {
        predicate = Property(initial)
        super.init()
        
        delegate = DelegateImpl(subject: subject, source: self)
        queue.sync {
            self.context = NSManagedObjectContext(parent: parent, merge: true)
            
            fetched = createFR(context: self.context, predicate: initial, order: order)
            fetched.delegate = delegate
        }
        
        
        predicate.with(weak: self).observeNext{ pred, s in
            s.context.async{ _ in
                s.fetched.fetchRequest.predicate = pred
                try s.fetched.performFetch()
                
                }.onSuccess {_ in
                    self.subject.next(ObservableArrayEvent(change: .reset, source: self.array))
                }.onFailure{ error in
                     self.subject.failed(error)
                }
            }.dispose(in: bag)
    }
    
    deinit {
        print("deinit", type(of: self))
    }
    
}
extension CoreDataFetchedObservable {
    
    class BatchUpdater {
        
        var changes: [ObservableArrayChange] = []
        
        init(){
            
        }
        func add(change: ObservableArrayChange) {
            changes.append(change)
        }
        func populate(to subject: PublishSubject<ObservableArrayEvent<Item>>, with items: Array<Item>) {
            
            if changes.count > 40 {
                subject.next(ObservableArrayEvent(change: .reset, source: items))
            } else if changes.count > 0 {
                // ...otherwise batch:
                subject.next(ObservableArrayEvent(change: .beginBatchEditing, source: items))
                changes.forEach { change in
                    subject.next(ObservableArrayEvent(change: change, source: items))
                }
                subject.next(ObservableArrayEvent(change: .endBatchEditing, source: items))
            }
            
        }
    }
    
    class DelegateImpl : NSObject, NSFetchedResultsControllerDelegate {
        weak var subject: PublishSubject<ObservableArrayEvent<Item>>?
        weak var source: CoreDataFetchedObservable?
        
        
        init(subject: PublishSubject<ObservableArrayEvent<Item>>, source : CoreDataFetchedObservable) {
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
            batchUpdater?.populate(to: subject, with: source.array)
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


