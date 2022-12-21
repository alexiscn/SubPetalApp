//
//  SubsonicResponse.swift
//  
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation

public protocol Response: Codable {
    
    var status: String { get }
    var version: String { get }
    var type: String? { get }
    var serverVersion: String? { get }
    var error: SubsonicError? { get }
}

struct SubsonicResponse<T: Response>: Codable {
    
    enum CodingKeys: String, CodingKey {
        case response = "subsonic-response"
    }
    
    let response: T
}
