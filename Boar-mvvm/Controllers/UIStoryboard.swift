//
//  UIStoryboard.swift
//  Boar-ReactiveIOS
//
//  Created by Peter Ovchinnikov on 1/23/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

extension UIStoryboard {
    func instantiate<T, VC: ViewController>(for: T.Type)-> VC? where VC.Service == T {
        let vc = instantiateViewController(withIdentifier: T.controllerName)
        return vc as? VC
    }
}
