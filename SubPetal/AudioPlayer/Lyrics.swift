//
//  Lyrics.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation

struct Lyrics {
    
    var artist: String? = nil
    
    var album: String? = nil
    
    var by: String? = nil
    
    var sentences: [Sentence] = []
    
    struct Sentence {
        
        var start: Int
        
        var content: String
    }
}
