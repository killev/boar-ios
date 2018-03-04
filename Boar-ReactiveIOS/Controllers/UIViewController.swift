//
//  UIViewController.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Foundation
import ReactiveKit
import BrightFutures

public protocol VCService {
    func reload()
    func reload(code: String)
}

extension VCService {
    static var controllerName: String { return ":" }
    
}
struct ViewControllerInfo {
    let storyboard: String
    let identifier: String
}
protocol ViewControllerBase: NSObjectProtocol {
    var _vc: VCService? {get set}
}
protocol ViewController : ViewControllerBase {
    associatedtype Service: VCService
    func advise(service: Service)
}
extension ViewController {
    static var nameInfo: String { return "" }
}

extension UIViewController {
    
    private static let swizzle: Void = {
        func registerSwizzle(_ originalSelector:Selector, swizzledSelector : Selector, clazz: AnyClass) {
            let originalMethod = class_getInstanceMethod(clazz, originalSelector)
            let swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector)
            
            let didAddMethod = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            
            if didAddMethod {
                class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
        registerSwizzle(#selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.nsh_viewDidAppear(_:)), clazz:UIViewController.self)
        registerSwizzle(#selector(UIViewController.viewWillAppear(_:)), swizzledSelector: #selector(UIViewController.nsh_viewWillAppear(_:)), clazz:UIViewController.self)
        registerSwizzle(#selector(UIViewController.viewDidDisappear(_:)), swizzledSelector: #selector(UIViewController.nsh_viewDidDisappear(_:)), clazz:UIViewController.self)
        registerSwizzle(#selector(UIViewController.viewWillDisappear(_:)), swizzledSelector: #selector(UIViewController.nsh_viewWillDisappear(_:)), clazz:UIViewController.self)
        registerSwizzle(#selector(UIViewController.viewDidLoad), swizzledSelector: #selector(UIViewController.nsh_viewDidLoad), clazz:UIViewController.self)
    }()
    
    public static func setup() {
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        UIViewController.swizzle
    }
    
    @objc func nsh_viewDidLoad() {
        self.nsh_viewDidLoad()
        if let lc = self as? VCLifeCycle {
            lc.viewDidLoadImpl()
        }
        reactive.viewDidLoadPromise.success(self)
       
    }
    @objc func nsh_viewDidAppear(_ animated: Bool) {
        self.nsh_viewDidAppear(animated)
        
    }
    @objc  func nsh_viewWillAppear(_ animated: Bool) {
        self.nsh_viewWillAppear(animated)
        if let lc = self as? VCLifeCycle {
            lc.viewWillAppearImpl()
        }
        reactive.viewWillAppear.next(self)
    }
    @objc func nsh_viewWillDisappear(_ animated: Bool) {
        self.nsh_viewWillDisappear(animated)
    }
    @objc func nsh_viewDidDisappear(_ animated: Bool) {
        self.nsh_viewDidDisappear(animated)
        //unadvice()
    }
}

public protocol VCLifeCycle {
    func viewDidLoadImpl()
    func viewWillAppearImpl()
}


// public extension VCLifeCycle where Self: UIViewController {
//    func viewDidLoadImpl() {
//    }
//    func viewWillAppearImpl(){
//    }
//}

public extension VCLifeCycle where Self: UIViewController {
    func viewDidLoadImpl() {
     //   advise(viewModel: viewModel)
    }
    func viewWillAppearImpl(){
        
    }
}



fileprivate struct ReactiveExtensionKeys{
    static var viewWillAppearKey = "viewWillAppearKey"
}
extension ReactiveExtensions where Base: UIViewController {
    
    var viewWillAppear: SafePublishSubject<UIViewController> {
        return dynamicROProperty(object: self, &ReactiveExtensionKeys.viewWillAppearKey){
            SafePublishSubject<UIViewController>()
        }
    }
    
    fileprivate
    var viewDidLoadPromise: Promise<UIViewController, NSError> {
        return dynamicROProperty(object: self, &ReactiveExtensionKeys.viewWillAppearKey){
            Promise<UIViewController, NSError> ()
        }
    }
    
    var viewDidLoad: Future<UIViewController, NSError> {
        return viewDidLoadPromise.future
    }
}





