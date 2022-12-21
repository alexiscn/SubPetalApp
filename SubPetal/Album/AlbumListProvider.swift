//
//  AlbumListProvider.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation
import SubsonicKit

protocol AlbumListDataProvider {
    
    func loadData(offset: Int) async -> [Album]
    
}

class AlbumListProvider: AlbumListDataProvider {
    
    var type: AlbumListType
    
    init(type: AlbumListType) {
        self.type = type
    }
    
    func loadData(offset: Int) async -> [Album] {
        do {
            let response = try await Context.current?.client.getAlbumList2(type: type, size: 20, offset: offset).albumList2.album
            return response ?? []
        } catch {
            print(error)
        }
        return []
    }
}

class StarredAlbumListProvider: AlbumListDataProvider {
    
    func loadData(offset: Int) async -> [Album] {
        do {
            let starred = try await Context.current?.client.getStarred2().starred2
            return starred?.album?.uniqued() ?? []
        } catch {
            print(error)
        }
        return []
    }
}

class ArtistAlbumListProvider: AlbumListDataProvider {
    
    var artistId: String
    
    init(artistId: String) {
        self.artistId = artistId
    }
    
    func loadData(offset: Int) async -> [Album] {
        do {
            let response = try await Context.current?.client.getMusicDirectory(id: artistId)
            return response?.directory.child ?? []
        } catch {
            print(error)
        }
        return []
    }
}
