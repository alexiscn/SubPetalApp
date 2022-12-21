//
//  TopSongs.swift
//  
//
//  Created by alexiscn on 2022/6/3.
//

import Foundation

public struct TopSongsResponse: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let topSongs: TopSongs
}
