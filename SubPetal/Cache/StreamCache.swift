//
//  StreamCache.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/7.
//

import Foundation
import SubsonicKit
import Tiercel
import UIKit

class StreamCache {
    
    let directoryPath: String
    var songs = [String: Song]()
    var downloadingTasks: [Tiercel.DownloadTask] = []
    
    var manager: SessionManager? { Context.current?.sessionManager }
    
    init(directory: String) {
        directoryPath = directory.appending("/Streaming")
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: directoryPath), withIntermediateDirectories: true)
    }
    
    func hasDownloaded(_ song: Song) -> Bool {
        let url = cacheFileURL(for: song)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func loadDownloaded() -> [Song] {
        // TODO - use completion block
        var result = [Song]()
        let contents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath)
        for content in contents ?? [] {
            if content.hasSuffix(".json") {
                do {
                    let url = URL(fileURLWithPath: directoryPath.appending("/\(content)"))
                    let data = try Data(contentsOf: url)
                    let song = try JSONDecoder().decode(Song.self, from: data)
                    if hasDownloaded(song) {
                        result.append(song)
                    }
                } catch {
                    print(error)
                }
            }
        }
        return result
    }
    
    func download(_ song: Song) {
        guard !hasDownloaded(song) else {
            return
        }
        guard let url = Context.current?.client.stream(id: song.id) else {
            return
        }
        if downloadingTasks.contains(where: { $0.url == url }) {
            return
        }
        let fileURL = cacheFileURL(for: song)
        guard let task = manager?.download(url, fileName: fileURL.lastPathComponent) else {
            return
        }
        let metaURL = metadataURL(for: song)
        try? song.data.write(to: metaURL)
        downloadingTasks.append(task)
    }
    
    func cacheFileURL(for song: Song) -> URL {
        let suffix = song.suffix ?? "tmp"
        return URL(fileURLWithPath: directoryPath.appending("/\(song.id).\(suffix)"))
    }
    
    func metadataURL(for song: Song) -> URL {
        return URL(fileURLWithPath: directoryPath.appending("/\(song.id).json"))
    }
    
    func loadSong(id: String) -> Song? {
        if let song = songs[id] {
            return song
        } else {
            let fileURL = URL(fileURLWithPath: directoryPath.appending("/\(id).json"))
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let song = try JSONDecoder().decode(Song.self, from: data)
                    songs[id] = song
                    return song
                } catch {
                    print(error)
                }
            }
            return nil
        }
    }
    
    func delete(song: Song) {
        let fileURL = cacheFileURL(for: song)
        let jsonURL = metadataURL(for: song)
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: jsonURL)
    }
    
    func prune() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            if contents.count > 100 {
                
            }
        } catch {
            print(error)
        }
    }
}
