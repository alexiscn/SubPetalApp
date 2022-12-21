//
//  ListCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit
import Kingfisher

class ListCell: UICollectionViewCell {
    
    let coverView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let separatorView = UIView()
    
    var size: Int {
        return Int(100 * UIScreen.main.scale)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverView.contentMode = .scaleAspectFill
        coverView.layer.cornerRadius = 6
        coverView.layer.masksToBounds = true
        coverView.backgroundColor = .secondarySystemBackground
        
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = 5
        
        separatorView.backgroundColor = .separator
        
        contentView.addSubview(coverView)
        contentView.addSubview(stackView)
        contentView.addSubview(separatorView)
        
        coverView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverView.heightAnchor.constraint(equalToConstant: 50),
            coverView.widthAnchor.constraint(equalToConstant: 50),
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            coverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.leadingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1/UIScreen.main.scale)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ song: Song) {
        let url = Context.coverArtURL(song: song)
        coverView.kf.setImage(with: url)
        titleLabel.text = song.title
        subtitleLabel.text = song.artist
    }
    
    func render(_ artist: Artist) {
        let url = Context.coverArtURL(artist: artist)
        coverView.kf.setImage(with: url)
        titleLabel.text = artist.name
    }
    
    func render(_ album: Album) {
        let url = Context.coverArtURL(album: album)
        coverView.kf.setImage(with: url)
        titleLabel.text = album.title
        
        var subtitles = [String]()
        if let artist = album.artist {
            subtitles.append(artist)
        }
        if let songCount = album.songCount {
            subtitles.append("\(songCount) songs")
        }
        subtitleLabel.text = subtitles.joined(separator: " - ")
    }
    
    func render(_ playlist: Playlist) {
        coverView.image = UIImage(systemName: "music.note.list")
        titleLabel.text = playlist.name
        
        var subtitles = [String]()
        if let count = playlist.songCount {
            subtitles.append("\(count) items")
        }
        if let duration = playlist.duration,
            let length = Formatter.playlistDurationFormatter.string(from: TimeInterval(duration)) {
            subtitles.append(length)
        }
        subtitleLabel.text = subtitles.joined(separator: " ")
    }
}
