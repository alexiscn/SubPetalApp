//
//  LyricsResponse.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct LyricsResponse: Response {
    
    public var status: String
    
    public var version: String
    
    public var type: String?
    
    public var serverVersion: String?
    
    public var error: SubsonicError?
    
    public let lyrics: Lyrics
    
}
