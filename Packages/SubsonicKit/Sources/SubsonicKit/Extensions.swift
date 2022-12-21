//
//  Extensions.swift
//  
//
//  Created by alexiscn on 2022/6/2.
//

import Foundation
import CryptoKit

extension String {
    
    var md5: String {
        let data = self.data(using: .utf8) ?? Data()
        return Insecure.MD5.hash(data: data).toHexString()
    }
    
    var salt: String {
        let text = self.md5
        if text.count > 6 {
            return String(text[text.startIndex ..< text.index(text.startIndex, offsetBy: 6)])
        }
        return text
    }
    
    static func randomSalt(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var result = ""
        for _ in 0 ..< length {
            let index = Int.random(in: 0 ..< letters.count)
            let text = letters[letters.index(letters.startIndex, offsetBy: index) ..< letters.index(letters.startIndex, offsetBy: index + 1)]
            result += text
        }
        return result
    }
}

extension Digest {
    
    func toHexString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}

extension Sequence where Iterator.Element: Hashable {
    public func uniqued() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
