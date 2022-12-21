//
//  ContextMenuPlayHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/10.
//

import Foundation
import SubsonicKit
import UIKit

struct ContextMenuPlayHandler: ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo) {
        if let song = info.item as? Song {
            let songs = info.list.compactMap { $0 as? Song }
            let index = songs.firstIndex(where: { $0.id == song.id }) ?? 0
            AudioPlayerManager.shared.play(songs, at: index)
        }
    }
}
