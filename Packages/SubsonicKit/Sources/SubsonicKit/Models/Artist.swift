//
//  Artist.swift
//  
//
//  Created by alexiscn on 2022/5/18.
//

import Foundation

public class Artist: Codable, Hashable {
    public let id: String
    public let name: String?
    public let coverArt: String?
    public let orderArtistName: String?
    public let albumCount: Int?
    public let externalInfoUpdatedAt: String?
    public let fullText: String?
    //public let genres: null
    public let playCount: Int?
    public let playDate: String?
    public let rating: Float?

    public let size: Int64?
    public let songCount: Int?
    public var starred: String?
    public let starredAt: String?
    public let album: [Album]?
    public let artistImageUrl: String?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
}
