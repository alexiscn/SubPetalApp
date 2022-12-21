//
//  ArtistInfo2Response.swift
//  
//
//  Created by alexiscn on 2022/6/3.
//

import Foundation

public struct ArtistInfo2Response: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let artistInfo2: ArtistInfo2
}
