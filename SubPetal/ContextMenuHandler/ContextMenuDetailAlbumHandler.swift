//
//  ContextMenuViewDetailHandler.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/12.
//

import Foundation
import SubsonicKit
import UIKit

struct ContextMenuViewDetailHandler: ContextMenuHandler {

    static func handle(_ info: ContextMenuInfo) {
        if let album = info.item as? Album {
            let vc = AlbumProfileViewController(album: album)
            info.viewController.navigationController?.pushViewController(vc, animated: true)
        } else if let artist = info.item as? Artist {
            let vc = ArtistProfileViewController(artist: artist)
            info.viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
