//
//  SubsonicError.swift
//  
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation

public struct SubsonicError: Codable {
    public let code: Int
    public let message: String
    
    public func asNSError() -> NSError {
        return NSError(domain: "", code: code, userInfo: [
            NSLocalizedFailureErrorKey: message
        ])
    }
}
