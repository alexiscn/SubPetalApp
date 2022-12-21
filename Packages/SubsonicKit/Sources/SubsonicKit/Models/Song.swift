//
//  Song.swift
//  
//
//  Created by alexiscn on 2022/5/18.
//

import Foundation

public class Song: Codable, Hashable {
    
    public let id: String
    public let parent: String?
    public let track: Int?
    public let title: String?
    public let album: String?
    public let artist: String?
    public let isDir: Bool?
    public let coverArt: String?
    public let path: String?
    public let albumId: String?
    public let artistId: String?
    public let type: String?
    public let size: Int64?
    public let created: String?
    public let contentType: String?
    public let year: Int?
    public let suffix: String?
    public let duration: Int?
    public let bitRate: Int?
    public let discNumber: Int?
    public var starred: String?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}
