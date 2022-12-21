//
//  Bookmark.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct Bookmark: Codable, Hashable {
    
    public let position: Int64?
    
    public let entry: [Song]?
    
}
