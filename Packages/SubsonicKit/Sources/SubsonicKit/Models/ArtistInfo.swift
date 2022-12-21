//
//  ArtistInfo.swift
//  
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation

public struct ArtistInfo: Codable, Hashable {
    public let biography: String?
    public let musicBrainzId: String?
    public let lastFmUrl: String?
    public let smallImageUrl: String?
    public let mediumImageUrl: String?
    public let largeImageUrl: String?
    public let similarArtist: [Artist]?
}
