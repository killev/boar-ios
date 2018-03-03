//
//  Router.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import ReactiveKit



enum VCStyle {
    case tab(name: String)
    case root(name: String, data: String)
    case push(name: String, data: String)
    case present(name: String, data: String)
}




class Router {
    
    //    var path_tmp = "tab:Map/push:chat{cousin:\"sdgsdfgsdg\"}/present:message{}"
    //    let path = Array<VCStyle>()
    //
    //    private var viewController: UIViewController?
    //
    //
    //    func verifyTab(vc: UIViewController, name: String, data: String) -> UIViewController? {
    //        return nil
    //    }
    //    func createTab(vc: UIViewController, name: String, data: String) -> UIViewController? {
    //        return nil
    //    }
    
    //    private func updateControllers(newPath: String){
    //
    //        var vc: UIViewController? = viewController
    //
    //        for vcStyle in path {
    //            switch vcStyle {
    //            case .tab(let name, let data):
    //                if let current = vc {
    //                    vc = verifyTab(vc: current, name: name, data: data)
    //                } else {
    //                    vc = createTab(name, data, data: data)
    //                }
    //            case .push(let name, let data): print(name, data)
    //            case .present(let name, let data): print(name, data)
    //            }
    //        }
    //    }
    
    
    
//    func present<T:VCService>(animated: Bool) -> AtomicObserver<T> {
//        return AtomicObserver(disposable: NonDisposable.instance) { event in
//            switch event {
//            case .next(let vcService):
//                let vc = UIStoryboard(name: T.controllerName, bundle: nil)
//                    .instantiateViewController(withIdentifier: T.controllerName)
//
//                if let vc = vc as? CellBase {
//                    vc._vm = vcService
//                }
//
//                Router.topViewController()?.present(vc, animated: animated)
//
//            default: break
//            }
//        }
//    }
//    static func asVC<T, VC: ViewController>(_ vcType: T.Type, vc: UIViewController)->VC? where VC.Service == T{
//        return vc as? VC
//    }
    
}

extension Router {
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    
    class func tabBarViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UITabBarController? {
        
        if let tab = base as? UITabBarController {
            return tab
        }else {
            return base?.tabBarController
        }
    }
    
    class func topView()->UIView? {
        var view = topViewController()?.view
        
        while view != nil && view?.superview != nil {
            view = view!.superview
        }
        return view
    }
    
    
    //    class func openTab<T: UIViewController>(root: T.Type,
    //                                            popToRootController: Bool, delay : TimeInterval = 0)->Future<T, NSError> {
    //
    //        guard let tabBarController = tabBarViewController() else {
    //            return Future(error: Error.invalidLogic("topViewController has no tabBarController" ))
    //        }
    //
    //        guard let items = tabBarController.tabBar.items else {
    //            return Future(error: Error.invalidLogic("tabBarController has no items" ))
    //
    //        }
    //
    //        for (idx, item) in items.enumerated() {
    //
    //            var controller = tabBarController.viewControllers![idx]
    //
    //            if controller is UINavigationController {
    //                controller = controller.childViewControllers[0]
    //            }
    //
    //            if let controller = controller as? T {
    //
    //                if popToRootController {
    //                    controller.navigationController?.popToRootViewController(animated: false)
    //                }
    //
    //                if tabBarController.selectedIndex != idx {
    //                    let promise = Promise<T, NSError>()
    //                    let untyped = { (_:UIViewController) in
    //                        promise.success(controller)
    //                    }
    //
    //                    controller.viewDidAppearResolvers.append((delay, untyped))
    //
    //                    tabBarController.delegate?.tabBarController?(tabBarController, shouldSelect: controller)
    //                    tabBarController.selectedIndex = idx
    //
    //                    return promise.future
    //
    //                } else {
    //                    return Future(value: controller)
    //                }
    //            }
    //        }
    //        return Future(error: Error.invalidLogic("No valid tab" ))
    //    }
}
