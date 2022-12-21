//
//  ContextMenuStarHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/10.
//

import Foundation
import SubsonicKit
import UIKit

struct ContextMenuStarHandler: ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo) {
        Task {
            if let song = info.item as? Song {
                await handle(song)
            } else if let album = info.item as? Album {
                await handle(album)
            } else if let artist = info.item as? Artist {
                await handle(artist)
            }
        }
    }
    
    @discardableResult
    static func handle(_ album: Album) async -> Bool {
        do {
            if album.starred == nil {
                try await Context.current?.client.star(albumId: album.id)
                album.starred = ISO3601DateFormatter.shared.string(from: Date())
            } else {
                try await Context.current?.client.unstar(albumId: album.id)
                album.starred = nil
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    @discardableResult
    static func handle(_ artist: Artist) async -> Bool {
        do {
            if artist.starred == nil {
                try await Context.current?.client.star(artistId: artist.id)
                artist.starred = ISO3601DateFormatter.shared.string(from: Date())
            } else {
                try await Context.current?.client.unstar(artistId: artist.id)
                artist.starred = nil
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    
    @discardableResult
    static func handle(_ song: Song) async -> Bool {
        do {
            if song.starred == nil {
                try await Context.current?.client.star(id: song.id)
                song.starred = ISO3601DateFormatter.shared.string(from: Date())
            } else {
                try await Context.current?.client.unstar(id: song.id)
                song.starred = nil
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
}
