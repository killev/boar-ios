//
//  UIViewController+Routing.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Boar_Reactive

extension UIViewController {
    
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool)->Future<Void> {
        let promise = Promise<Void>()
        self.present(viewControllerToPresent, animated: flag, completion: promise.success)
        return promise.future
    }
    
    @discardableResult
    func dismiss(animated flag: Bool) -> Future<Void>{
        let promise = Promise<Void>()
        self.dismiss(animated: flag, completion: promise.success)
        return promise.future
    }
}
