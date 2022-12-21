//
//  File.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct User: Codable, Hashable {
    public let username: String
    public let scrobblingEnabled: Bool?
    public let adminRole: Bool?
    public let settingsRole: Bool?
    public let downloadRole: Bool?
    public let uploadRole: Bool?
    public let playlistRole: Bool?
    public let coverArtRole: Bool?
    public let commentRole: Bool?
    public let podcastRole: Bool?
    public let streamRole: Bool?
    public let jukeboxRole: Bool?
    public let shareRole: Bool?
    public let videoConversionRole: Bool?

}
