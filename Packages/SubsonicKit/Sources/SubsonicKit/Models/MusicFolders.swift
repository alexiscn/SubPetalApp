//
//  MusicFolders.swift
//  
//
//  Created by alexiscn on 2022/5/18.
//

import Foundation

public struct MusicFolder: Codable {
    public let id: String
    public let name: String?
}

public struct MusicFolders: Codable {
    
    public let musicFolder: [MusicFolder]
}
