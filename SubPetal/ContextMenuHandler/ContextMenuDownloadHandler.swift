//
//  ContextMenuDownloadHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/13.
//

import Foundation
import UIKit
import SubsonicKit

struct ContextMenuDownloadHandler: ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo) {
        if let song = info.item as? Song {
            download(song)
        } else if let album = info.item as? Album {
            download(album)
        }
    }
    
    static func download(_ song: Song) {
        Context.current?.streamCache.download(song)
    }
    
    static func download(_ album: Album) {
        Task {
            do {
                if let songs = try await Context.current?.client.getAlbum(id: album.id).album.song, !songs.isEmpty {
                    songs.forEach { download($0) }
                }
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
}
