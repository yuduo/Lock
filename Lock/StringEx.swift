//
//  StringEx.swift
//  Lock
//
//  Created by yong hu on 2018/11/29.
//  Copyright © 2018 yong hu. All rights reserved.
//

import UIKit

extension String {
    
    func base64Encoded() -> String {
        let plainData = data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    
    func base64Decoded() -> String {
        let decodedData = NSData(base64Encoded: self, options:NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)
        return decodedString! as String
    }
}
