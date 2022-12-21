//
//  SimilarSongs2Response.swift
//  
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation

public struct SimilarSongs2Response: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let similarSongs2: SimilarSongs2
}
