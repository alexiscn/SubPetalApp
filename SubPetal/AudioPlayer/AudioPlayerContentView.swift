//
//  AudioPlayerContentView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/7.
//

import UIKit
import SubsonicKit

class AudioPlayerContentView: UIView {
    
    enum Content {
        case lyrics
        case playlist
    }
    
    var lyricsView: AudioPlayerLyricsView!
    
    var playlistView: AudioPlaylistView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lyricsView = AudioPlayerLyricsView()
        lyricsView.isHidden = true
        addSubview(lyricsView)
        
        playlistView = AudioPlaylistView(frame: bounds)
        playlistView.isHidden = true
        addSubview(playlistView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lyricsView.frame = bounds
        playlistView.frame = bounds
    }
    
    func show(content: Content) {
        lyricsView.isHidden = true
        playlistView.isHidden = true
        
        switch content {
        case .playlist:
            if let song = AudioPlayerManager.shared.playingSong {
                playlistView.select(song: song)
            }
            playlistView.isHidden = false
        case .lyrics:
            lyricsView.isHidden = false
        }
    }
    
    func hide() {
        lyricsView.isHidden = true
        playlistView.isHidden = true
    }
    
    func fetchLyrics(for song: Song) {
        lyricsView.updateLyric(nil)
        lyricsView.loadingState = .loading
        
        if let lyrics = Context.current?.lyricsCache.loadLyrics(for: song) {
            lyricsView.loadingState = .success
            lyricsView.updateLyric(lyrics)
        } else {
            // TODO
        }
    }
}
