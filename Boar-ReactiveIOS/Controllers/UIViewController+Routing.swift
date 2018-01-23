//
//  UIViewController+Routing.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import BrightFutures

extension UIViewController {
    
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool)->Future<Void, NSError> {
        let promise = Promise<Void, NSError>()
        self.present(viewControllerToPresent, animated: flag, completion: promise.success)
        return promise.future
    }
    
    @discardableResult
    func dismiss(animated flag: Bool) -> Future<Void, NSError>{
        let promise = Promise<Void, NSError>()
        self.dismiss(animated: flag, completion: promise.success)
        return promise.future
    }
}
