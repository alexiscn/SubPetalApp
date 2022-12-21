//
//  Episode.swift
//  
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation

public struct Episode: Codable {
    
    public let id: String
    public let parent: String?
    public let isDir: Bool?
    public let title: String?
    public let album: String?
    public let artist: String?
    public let year: String?
    public let coverArt: String?
    public let size: Int64?
    public let contentType: String?
    public let suffix: String?
    public let duration: Int?
    
    public let bitRate: Int?
    public let isVideo: Bool?
    public let created: String?
    public let artistId: String?
    public let type: String?
    public let streamId: String
    public let channelId: String?
    public let description: String?
    public let status: String?
    public let publishDate: String?
    
}
