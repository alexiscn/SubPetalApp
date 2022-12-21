//
//  Playlist.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct Playlist: Codable, Hashable {
    public let id: String
    public let name: String?
    public let songCount: Int?
    public let duration: Int?
    public let `public`: Bool?
    public let owner: String?
    public let created: String?
    public let changed: String?
    public var entry: [Song]?
}
