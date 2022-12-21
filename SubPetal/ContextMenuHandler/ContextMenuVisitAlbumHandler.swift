//
//  ContextMenuVisitAlbumHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/16.
//

import UIKit
import SubsonicKit

struct ContextMenuVisitAlbumHandler: ContextMenuHandler {
    
    static func handle(_ info: ContextMenuInfo) {
        if let song = info.item as? Song, let albumId = song.albumId {
            visit(albumId: albumId, viewController: info.viewController)
        }
    }
    
    static func visit(albumId: String, viewController: UIViewController) {
        Task {
            HUD.showIndicator()
            do {
                let album = try await Context.current?.client.getAlbum(id: albumId).album
                if let album = album {
                    let vc = await AlbumProfileViewController(album: album)
                    await viewController.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                HUD.show(error: error.localizedDescription)
            }
            HUD.removeIndicator()
        }
    }
}
