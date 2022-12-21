//
//  AlbumInfoResponse.swift
//  
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation

public struct AlbumInfoResponse: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let albumInfo: AlbumInfo
}
