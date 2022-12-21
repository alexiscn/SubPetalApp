//
//  NowPlayingCenter.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/6.
//

import Foundation
import MediaPlayer
import SubsonicKit
import Kingfisher

struct NowPlayingCenter {
    
    static var song: Song? {
        didSet {
            artwork = nil
        }
    }
    static var artwork: UIImage?
    
    static func update() {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        if let song = song {
            info[MPMediaItemPropertyTitle] = song.title
            info[MPMediaItemPropertyArtist] = song.artist
            info[MPMediaItemPropertyAlbumTitle] = song.album
            if let artwork = artwork {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size, requestHandler: { _ in
                    artwork
                })
            } else {
                if let url = Context.coverArtURL(song: song) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let imageResult):
                            let image = imageResult.image
                            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in
                                image
                            })
                            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                            self.artwork = image
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
        info[MPMediaItemPropertyPlaybackDuration] = AudioPlayerManager.shared.duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioPlayerManager.shared.currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = AudioPlayerManager.shared.isPlaying ? 1.0: 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
}
