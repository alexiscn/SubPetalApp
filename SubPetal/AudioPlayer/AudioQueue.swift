//
//  AudioQueue.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import Foundation
import SubsonicKit
import UIKit
import Defaults

class AudioQueue: Codable {
    
    private var originSongs = [Song]()
    
    var songs: [Song] = []
    
    var currentIndex = 0
    
    var current: Song? {
        if currentIndex >= 0 && currentIndex < songs.count {
            return songs[currentIndex]
        }
        return nil
    }
    var next: Song? {
        guard songs.count > 0 else {
            return nil
        }
        let mode = Defaults[.repeatMode]
        switch mode {
        case .loop, .shuffle:
            if currentIndex == songs.count - 1 {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        case .one:
            break
        }
        return songs[currentIndex]
    }
    
    var previous: Song? {
        guard songs.count > 0 else {
            return nil
        }
        let mode = Defaults[.repeatMode]
        switch mode {
        case .loop, .shuffle:
            if currentIndex == 0 {
                currentIndex = songs.count - 1
            } else {
                currentIndex -= 1
            }
        case .one:
            break
        }
        return songs[currentIndex]
    }
    
    func shuffle() {
        songs = originSongs.shuffled()
    }
}
