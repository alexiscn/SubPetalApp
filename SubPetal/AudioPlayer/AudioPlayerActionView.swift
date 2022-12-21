//
//  AudioPlayerActionView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/5.
//

import UIKit
import Defaults

protocol AudioPlayerActionViewDelegate: AnyObject {
    
    func actionViewLyricsAction()
    
    func actionViewModeAction()
    
    func actionViewPlaylistAction()
}

class AudioPlayerActionView: UIView {
    
    weak var delegate: AudioPlayerActionViewDelegate?
    
    let lyricButton = UIButton(type: .system)
    
    let modeButton = UIButton(type: .custom)
    
    let playlistButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lyricButton.setImage(UIImage(systemName: "text.bubble"), for: [])
        lyricButton.tintColor = .label
        lyricButton.layer.cornerRadius = 5
        lyricButton.clipsToBounds = true
        
        modeButton.setImage(Defaults[.repeatMode].displayIcon, for: [])
        modeButton.tintColor = .label
        playlistButton.setImage(UIImage(systemName: "list.bullet"), for: [])
        playlistButton.tintColor = .label
        playlistButton.layer.cornerRadius = 5
        playlistButton.clipsToBounds = true
        
        addSubview(lyricButton)
        addSubview(modeButton)
        addSubview(playlistButton)
        
        lyricButton.addTarget(self, action: #selector(onLyricsButtonClicked), for: .touchUpInside)
        modeButton.addTarget(self, action: #selector(onModeButtonClicked), for: .touchUpInside)
        playlistButton.addTarget(self, action: #selector(onPlaylistButtonClicked), for: .touchUpInside)
        
        lyricButton.translatesAutoresizingMaskIntoConstraints = false
        modeButton.translatesAutoresizingMaskIntoConstraints = false
        playlistButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            lyricButton.widthAnchor.constraint(equalTo: heightAnchor),
            lyricButton.heightAnchor.constraint(equalTo: heightAnchor),
            lyricButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            lyricButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -100),
            
            modeButton.widthAnchor.constraint(equalTo: heightAnchor),
            modeButton.heightAnchor.constraint(equalTo: heightAnchor),
            modeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            modeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            playlistButton.widthAnchor.constraint(equalTo: heightAnchor),
            playlistButton.heightAnchor.constraint(equalTo: heightAnchor),
            playlistButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playlistButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 100),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onLyricsButtonClicked() {
        lyricButton.isSelected.toggle()
        playlistButton.isSelected = false
        delegate?.actionViewLyricsAction()
    }
    
    @objc private func onModeButtonClicked() {
        delegate?.actionViewModeAction()
    }
    
    @objc private func onPlaylistButtonClicked() {
        playlistButton.isSelected.toggle()
        lyricButton.isSelected = false
        delegate?.actionViewPlaylistAction()
    }
}
