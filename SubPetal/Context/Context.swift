//
//  Context.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import Foundation
import SubsonicKit
import Tiercel
import UIKit

class Context {
    
    static var current: Context?
    
    let account: Account
    let client: SubsonicClient
    let userCachesDirectory: String
    let libraryCache: LibraryCache
    let lyricsCache: LyricsCache
    let streamCache: StreamCache
    let sessionManager: SessionManager
    
    init(account: Account) {
        self.account = account
        self.client = account.makeSonicClient()
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        userCachesDirectory = cachesDirectory.appending("/\(account.identfier)")
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: cachesDirectory), withIntermediateDirectories: true)
        libraryCache = LibraryCache(userDirectory: userCachesDirectory)
        lyricsCache = LyricsCache(userDirectory: userCachesDirectory)
        streamCache = StreamCache(directory: userCachesDirectory)
        
        let cache = Cache(account.identfier, downloadPath: userCachesDirectory, downloadFilePath: streamCache.directoryPath)
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        configuration.maxConcurrentTasksLimit = 2
        sessionManager = SessionManager("default", configuration: configuration, cache: cache)
    }
}

extension Context {
    
    static func coverArtURL(song: Song) -> URL? {
        return current?.client.getCoverArt(id: song.coverArt ?? song.id, size: 600)
    }
    
    static func coverArtURL(album: Album) -> URL? {
        return current?.client.getCoverArt(id: album.coverArt ?? album.id, size: 600)
    }
    
    static func coverArtURL(artist: Artist) -> URL? {
        return current?.client.getCoverArt(id: artist.coverArt ?? artist.id, size: 600)
    }
}
