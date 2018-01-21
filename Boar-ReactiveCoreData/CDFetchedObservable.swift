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
    
    var _array : [Item] = []
    
    override public var array: [Item]{
        return _array
    }
    private let queue = DispatchQueue(label: "com.boar.core-data-fetched-\(UUID().uuidString)", attributes: DispatchQueue.Attributes())
    
    
    private var context : NSManagedObjectContext!
    
    private var delegate: DelegateImpl!
    private var fetched: NSFetchedResultsController<Item>!
    
    init(parent: NSManagedObjectContext, initial: NSPredicate = NSPredicate(value: false), order: [(String,Bool)]) {
        super.init()
        delegate = DelegateImpl(subject: subject, source: self)
        queue.sync {
            self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            self.context.parent = parent
            self.context.automaticallyMergesChangesFromParent = true
            
            fetched = createFR(context: self.context, predicate: initial, order: order)
            fetched.delegate = delegate
        }
        
        _ = self.context.async{ _ in
            try self.fetched.performFetch()
            }.onSuccess {_ in
                self.lock.lock(); defer { self.lock.unlock() }
                self._array = self.fetched.fetchedObjects ?? []
                self.subject.next(ObservableArrayEvent(change: .reset, source: self._array))
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
            source.lock.lock(); defer{source.lock.unlock()}
            source._array = source.fetched.fetchedObjects ?? []
            
            let diff = generateDiff(from: changes)
            
            // if only reset, do not batch:
            if diff == [.reset] {
                subject.next(ObservableArrayEvent(change: .reset, source: source._array))
            } else if diff.count > 0 {
                // ...otherwise batch:
                subject.next(ObservableArrayEvent(change: .beginBatchEditing, source: source._array))
                diff.forEach { change in
                    subject.next(ObservableArrayEvent(change: change, source: source._array))
                }
                subject.next(ObservableArrayEvent(change: .endBatchEditing, source: source._array))
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


//extension CDFetchedObservable : ReactiveExtensionsProvider, CDFetchedObservableProtocol, DisposeBagProvider {
//
//}
//extension CDFetchedObservableProtocol  {
////  private struct AssociatedKeys {
////    static var DisposeBagKey = "DisposeBagKey"
////  }
////
////  /// A `DisposeBag` that can be used to dispose observations and bindings.
////  public var bag: DisposeBag {
////    if let disposeBag = objc_getAssociatedObject(self, &NSObject.AssociatedKeys.DisposeBagKey) {
////      return disposeBag as! DisposeBag
////    } else {
////      let disposeBag = DisposeBag()
////      objc_setAssociatedObject(self, &NSObject.AssociatedKeys.DisposeBagKey, disposeBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
////      return disposeBag
////    }
////  }
//
//}

//extension ReactiveExtensions where Base: CDFetchedObservableProtocol, Base: DisposeBagProvider {
//
//  /// A signal that fires completion event when the object is deallocated.
//  internal var deallocated: SafeSignal<Void> {
//    return base.bag.deallocated
//  }
//
//  /// A `DisposeBag` that can be used to dispose observations and bindings.
//  internal var bag: DisposeBag {
//    return base.bag
//  }
//}

