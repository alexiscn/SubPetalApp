//
//  LyricsCache.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/9.
//

import Foundation
import SubsonicKit

class LyricsCache {
    
    let folderPath: String
    
    init(userDirectory: String) {
        folderPath = userDirectory.appending("/Lyrics")
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: folderPath), withIntermediateDirectories: true)
    }
    
    func loadLyrics(for song: Song) -> Lyrics? {
        let url = localLyricsURL(for: song)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let content = try String(contentsOfFile: url.path)
            if let lyrics = LyricsParser.parse(content: content) {
                return lyrics
            } else {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func saveLyrics(content: String, for song: Song) {
        do {
            let url = localLyricsURL(for: song)
            try content.data(using: .utf8)?.write(to: url)
        } catch {
            print(error)
        }
    }
    
    private func localLyricsURL(for song: Song) -> URL {
        return URL(fileURLWithPath: folderPath.appending("/\(song.id).lrc"))
    }
}
