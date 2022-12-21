//
//  ArtistListDataProvider.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/16.
//

import Foundation
import SubsonicKit

protocol ArtistListDataProvider {
    
    func loadData(offset: Int) async -> [Artist]
    
}


class StarredArtistListProvider: ArtistListDataProvider {
    
    func loadData(offset: Int) async -> [Artist] {
        do {
            let response = try await Context.current?.client.getStarred2().starred2.artist
            return response ?? []
        } catch {
            print(error)
        }
        return []
    }

}
