//
//  SongListCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/2.
//

import UIKit
import SubsonicKit
import Kingfisher

class SongListCell: UICollectionViewCell {
    
    let coverView = UIImageView()
    
    let titleLabel = UILabel()
    
    let artistLabel = UILabel()
    
    let separatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverView.contentMode = .scaleAspectFill
        coverView.layer.cornerRadius = 6
        coverView.layer.masksToBounds = true
        coverView.backgroundColor = .secondarySystemBackground
        
        artistLabel.textColor = .secondaryLabel
        artistLabel.font = .preferredFont(forTextStyle: .footnote)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.axis = .vertical
        
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
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            coverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
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
        artistLabel.text = song.artist
    }
}
