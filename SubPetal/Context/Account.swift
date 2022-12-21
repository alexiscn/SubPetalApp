//
//  Account.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import Foundation
import SubsonicKit

class Account: Codable, Hashable {

    let identfier: String
    let baseURL: URL
    var name: String
    var username: String
    var password: String
    
    init(baseURL: URL, name: String) {
        self.identfier = UUID().uuidString
        self.baseURL = baseURL
        self.name = name
        self.username = ""
        self.password = ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identfier)
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.identfier == rhs.identfier
    }
}

extension Account {
    
    func makeSonicClient() -> SubsonicClient {
        let client = SubsonicClient(baseURL: baseURL, username: username, password: password)
        client.clientName = "SubPetal"
        return client
    }
}

