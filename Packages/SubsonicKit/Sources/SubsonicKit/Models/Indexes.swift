//
//  Indexes.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct Indexes: Codable {
    
    public let lastModified: Int64?
    
    public let ignoredArticles: String?
    
    public let index: [Index]
}
