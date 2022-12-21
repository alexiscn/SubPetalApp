//
//  PlaylistHeaderView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/9.
//

import UIKit
import Foundation
import SubsonicKit

protocol PlaylistHeaderViewDelegate: AnyObject {
    func playlistHeaderPlayAction()
    func playlistHeaderShuffleAction()
}

class PlaylistHeaderView: UICollectionReusableView {
    
    weak var delegate: PlaylistHeaderViewDelegate?
    
    let artworkView = AlbumArtworkView()
    
    let titleLabel = UILabel()
    
    let subtitleLabel = UILabel()
    
    let playButton = UIButton(configuration: .gray())
    
    let shuffleButton = UIButton(configuration: .gray())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        
        addSubview(artworkView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12, weight: .bold))
        
        playButton.configuration?.image = UIImage(systemName: "play.fill", withConfiguration: config)
        playButton.configuration?.title = "Play"
        playButton.configuration?.imagePadding = 8
        playButton.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.playlistHeaderPlayAction()
        }), for: .primaryActionTriggered)
        
        shuffleButton.configuration?.image = UIImage(systemName: "shuffle", withConfiguration: config)
        shuffleButton.configuration?.title = "Shuffle"
        shuffleButton.configuration?.imagePadding = 8
        shuffleButton.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.playlistHeaderShuffleAction()
        }), for: .primaryActionTriggered)
        
        let buttonStack = UIStackView(arrangedSubviews: [playButton, shuffleButton])
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        addSubview(buttonStack)
        
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artworkView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            artworkView.widthAnchor.constraint(equalToConstant: 270),
            artworkView.heightAnchor.constraint(equalToConstant: 270),
            artworkView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.topAnchor.constraint(equalTo: artworkView.bottomAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ playlist: Playlist) {
        
        titleLabel.text = playlist.name
    }
}
