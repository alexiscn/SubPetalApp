//
//  Genre.swift
//  
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

public struct Genre: Codable, Hashable {
    public let songCount: Int
    public let albumCount: Int
    public let value: String?
}
