//
//  ContextMenuVisitArtistHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/16.
//

import Foundation
import UIKit
import SubsonicKit

struct ContextMenuVisitArtistHandler: ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo) {
        if let album = info.item as? Album, let artistId = album.artistId {
            visit(artistId: artistId, viewController: info.viewController)
        } else if let song = info.item as? Song, let artistId = song.artistId {
            visit(artistId: artistId, viewController: info.viewController)
        }
    }
    
    static func visit(artistId: String, viewController: UIViewController) {
        Task {
            HUD.showIndicator()
            do {
                let artist = try await Context.current?.client.getArtist(id: artistId).artist
                if let artist = artist {
                    let vc = await ArtistProfileViewController(artist: artist)
                    await viewController.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                HUD.show(error: error.localizedDescription)
            }
            HUD.removeIndicator()
        }
    }
    
}
