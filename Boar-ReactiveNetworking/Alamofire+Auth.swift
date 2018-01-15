//
//  Alamofire+Auth.swift
//  Boar-ReactiveNetworking
//
//  Created by Peter Ovchinnikov on 1/15/18.
//  Copyright © 2018 Peter Ovchinnikov. All rights reserved.
//

import Alamofire

public struct Auth {
    
}
public extension Auth {
    static func basicToken(user:String, password: String) -> String {
        let credentialData           = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials        = credentialData.base64EncodedString(options: [])
        let token                    = "Basic \(base64Credentials)"
        return token
    }
    
    
    static func basic1(user:String, password: String) -> [String: String] {
        return ["Authorization": basicToken(user: user, password: password)]
    }
}
