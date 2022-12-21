//
//  HomeSection.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import Foundation
import UIKit

enum LibrarySection: String, Hashable {
    case artists
    case newestAlbums
    case randomSongs
    case starredAlbums
    case starredArtists
    case starredSongs
    case playlists
    
    var title: String? {
        switch self {
        case .newestAlbums: return "Newest Albums"
        case .randomSongs: return "Random Songs"
        case .starredAlbums: return "Starred Albums"
        case .starredSongs: return "Starred Songs"
        case .starredArtists: return "Starred Artists"
        case .playlists: return "Playlists"
        default: return nil
        }
    }
    
    var actionText: String? {
        switch self {
        case .starredSongs, .randomSongs: return "Shuffle"
        default: return "See All"
        }
    }
    
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch self {
        case .randomSongs: return .groupPaging
        default: return .continuous
        }
    }
}
