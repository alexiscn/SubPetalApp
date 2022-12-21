//
//  AlbumProfileHeaderView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit
import Kingfisher

protocol AlbumProfileHeaderViewDelegate: AnyObject {
    
    func albumProfileHeaderArtistAction()
    func albumProfileHeaderPlayAction()
    func albumProfileHeaderShuffleAction()
    
}

class AlbumProfileHeaderView: UICollectionReusableView {
    
    weak var delegate: AlbumProfileHeaderViewDelegate?
    
    let artworkView = AlbumArtworkView()
    
    let titleLabel = UILabel()
    
    let artistButton = UIButton(configuration: .plain())
    
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
        addSubview(artistButton)
        addSubview(subtitleLabel)
        
        artistButton.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.albumProfileHeaderArtistAction()
        }), for: .primaryActionTriggered)
        
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12, weight: .bold))
        
        playButton.configuration?.image = UIImage(systemName: "play.fill", withConfiguration: config)
        playButton.configuration?.title = "Play"
        playButton.configuration?.imagePadding = 8
        playButton.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.albumProfileHeaderPlayAction()
        }), for: .primaryActionTriggered)
        
        shuffleButton.configuration?.image = UIImage(systemName: "shuffle", withConfiguration: config)
        shuffleButton.configuration?.title = "Shuffle"
        shuffleButton.configuration?.imagePadding = 8
        shuffleButton.addAction(UIAction(handler: { [weak self] _ in
            self?.delegate?.albumProfileHeaderShuffleAction()
        }), for: .primaryActionTriggered)
        
        let buttonStack = UIStackView(arrangedSubviews: [playButton, shuffleButton])
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        addSubview(buttonStack)
        
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            artistButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            artistButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            artistButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.topAnchor.constraint(equalTo: artistButton.bottomAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ album: Album) {
        let url = Context.coverArtURL(album: album)
        artworkView.imageView.kf.setImage(with: url, placeholder: UIImage(named: "music_cover_300x300_"))
        titleLabel.text = album.name
        artistButton.configuration?.title = album.artist
        if let year = album.year {
            subtitleLabel.text = String(year)
        }
    }
}

class AlbumArtworkView: UIView {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor(white: 0, alpha: 0.5).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.5
        
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
}
