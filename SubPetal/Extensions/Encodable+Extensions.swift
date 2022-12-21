//
//  Encodable+Extensions.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/13.
//

import Foundation

extension Encodable {

    var data: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print(error)
            return Data()
        }
    }
    
    var json: String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
