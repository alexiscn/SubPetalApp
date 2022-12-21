//
//  ArtistListCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/4.
//

import UIKit
import Kingfisher
import SubsonicKit

class ArtistListCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        
        titleLabel.numberOfLines = 2
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.textAlignment = .center
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(_ artist: Artist) {
        imageView.layer.cornerRadius = bounds.width/2.0
        imageView.layer.masksToBounds = true
        imageView.kf.setImage(with: Context.coverArtURL(artist: artist))
        titleLabel.text = artist.name
    }
}
