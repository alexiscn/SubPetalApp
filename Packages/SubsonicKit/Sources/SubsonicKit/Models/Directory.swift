//
//  Directory.swift
//  
//
//  Created by alexiscn on 2022/6/22.
//

import Foundation

public struct Directory: Codable {
    
    public let id: String
    public let name: String?
    public let starred: String?
    public let albumCount: Int?
    public let child: [Album]?
}
