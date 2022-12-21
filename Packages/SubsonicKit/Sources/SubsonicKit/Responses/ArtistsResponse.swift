//
//  ArtistsResponse.swift
//  
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation

public class ArtistsResponse: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let artists: Artists
}
