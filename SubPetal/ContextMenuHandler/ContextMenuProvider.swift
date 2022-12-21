//
//  ContextMenuProvider.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/10.
//

import Foundation
import SubsonicKit
import UIKit

class ContextMenuProvider {
    
    static func contextMenu(for info: ContextMenuInfo) -> UIMenu? {
        
        let playAction = UIAction(title: "Play") { _ in
            ContextMenuPlayHandler.handle(info)
        }
        playAction.image = UIImage(systemName: "play")
        
        let shuffleAction = UIAction(title: "Shuffle") { _ in
            ContextMenuShuffleHandler.handle(info)
        }
        shuffleAction.image = UIImage(systemName: "shuffle")
        
        let addToPlaylistAction = UIAction(title: "Add to playlist") { _ in
            ContextMenuAddToPlaylistHandler.handle(info)
        }
        addToPlaylistAction.image = UIImage(systemName: "text.badge.plus")
        
        let starAction = UIAction(title: "Star") { _ in
            ContextMenuStarHandler.handle(info)
        }
        starAction.image = UIImage(systemName: "heart")
        
        let unstarAction = UIAction(title: "Unstar") { _ in
            ContextMenuStarHandler.handle(info)
        }
        unstarAction.image = UIImage(systemName: "heart.slash")
        
        let downloadAction = UIAction(title: "Download") { _ in
            ContextMenuDownloadHandler.handle(info)
        }
        downloadAction.image = UIImage(systemName: "icloud.and.arrow.down")
        
        let visitArtistAction = UIAction(title: "Visit Artist") { _ in
            ContextMenuVisitArtistHandler.handle(info)
        }
        visitArtistAction.image = UIImage(systemName: "person.crop.circle")
        
        let visitAlbumAction = UIAction(title: "Visit Album") { _ in
            ContextMenuVisitAlbumHandler.handle(info)
        }
        visitAlbumAction.image = UIImage(systemName: "rectangle.stack.fill")
        
        let infoAction = UIAction(title: "Get Info") { _ in
            
        }
        infoAction.image = UIImage(systemName: "info.circle")
        
        var children = [UIAction]()
        
        if let album = info.item as? Album {
            children.append(playAction)
            children.append(shuffleAction)
            if album.starred == nil {
                children.append(starAction)
            } else {
                children.append(unstarAction)
            }
            children.append(visitArtistAction)
            children.append(addToPlaylistAction)
            children.append(downloadAction)
            children.append(infoAction)
        } else if let song = info.item as? Song {
            children.append(playAction)
            if song.starred == nil {
                children.append(starAction)
            } else {
                children.append(unstarAction)
            }
            children.append(visitAlbumAction)
            children.append(visitArtistAction)
            children.append(downloadAction)
            children.append(addToPlaylistAction)
        } else if let artist = info.item as? Artist {
            if artist.starred == nil {
                children.append(starAction)
            } else {
                children.append(unstarAction)
            }
        }
        
        return UIMenu(children: children)
    }
}
