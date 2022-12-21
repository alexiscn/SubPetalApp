//
//  AlbumSongListCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/2.
//

import UIKit
import SubsonicKit

class AlbumSongListCell: UICollectionViewCell {
    
    let trackNumberLabel = UILabel()
    
    let titleLabel = UILabel()
    
    let subtitleLabel = UILabel()
    
    let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackNumberLabel.textAlignment = .center
        trackNumberLabel.textColor = .secondaryLabel
        
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel
        
        separatorView.backgroundColor = .separator
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        infoStack.spacing = 3
        infoStack.axis = .vertical
        infoStack.distribution = .fill
        
        let stackView = UIStackView(arrangedSubviews: [trackNumberLabel, infoStack])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        
        contentView.addSubview(separatorView)
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        trackNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackNumberLabel.widthAnchor.constraint(equalToConstant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: infoStack.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1/UIScreen.main.scale)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ song: Song) {
        if let track = song.track {
            trackNumberLabel.text = String(track)
        }
        titleLabel.text = song.title
        
        var subtitle = ""
        
        if let suffix = song.suffix {
            subtitle += suffix.uppercased()
            subtitle += "  "
        }
        
        if let duration = song.duration, let durationText = Formatter.format(TimeInterval(duration)) {
            subtitle += durationText
            subtitle += "  "
        }
        subtitleLabel.text = subtitle
    }
}
