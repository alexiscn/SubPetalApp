//
//  LibraryCache.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation

class LibraryCache {
    
    let folderPath: String
    
    init(userDirectory: String) {
        folderPath = userDirectory.appending("/LibraryCaches")
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: folderPath), withIntermediateDirectories: true)
    }
    
    private func cacheFileURL(section: LibrarySection) -> URL {
        let path = folderPath.appending("/\(section.rawValue).json")
        return URL(fileURLWithPath: path)
    }
    
    func load<T: Decodable>(section: LibrarySection) -> [T] {
        let url = cacheFileURL(section: section)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let items = try JSONDecoder().decode([T].self, from: data)
                return items
            } catch {
                print(error)
                return []
            }
        }
        return []
    }
    
    func save<T: Encodable>(items: [T], section: LibrarySection) {
        DispatchQueue.global().async {
            do {
                let url = self.cacheFileURL(section: section)
                let data = try JSONEncoder().encode(items)
                try data.write(to: url)
            } catch {
                print(error)
            }
        }
    }
    
}
