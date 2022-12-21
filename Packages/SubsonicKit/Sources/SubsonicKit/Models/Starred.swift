//
//  Starred.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct Starred: Codable {
    
    public let album: [Album]?
    
    public let artist: [Artist]?
    
    public let song: [Song]?
    
}
