//
//  Channel.swift
//  
//
//  Created by alexiscn on 2022/6/16.
//

import Foundation

public struct Channel: Codable {
    
    public let id: String
    public let url: String?
    public let title: String?
    public let description: String?
    public let coverArt: String?
    public let originalImageUrl: String?
    public let status: String?
    public let episode: [Episode]?
}
