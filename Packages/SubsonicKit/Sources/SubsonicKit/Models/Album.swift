//
//  Album.swift
//  
//
//  Created by alexiscn on 2022/5/18.
//

import Foundation

public class Album: Codable, Hashable {
    
    public let id: String
    public let parent: String?
    public let isDir: Bool?
    public let title: String?
    public let name: String?
    public let album: String?
    public let artist: String?
    public let year: Int?
    public let genre: String?
    public let coverArt: String?
    public let duration: Int?
    public let created: String?
    public let artistId: String?
    public let songCount: Int?
    public let isVideo: Bool?
    public var starred: String?
    public var song: [Song]?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
}
