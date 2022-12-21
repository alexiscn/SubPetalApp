//
//  GridCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/2.
//

import UIKit
import SubsonicKit
import Kingfisher

class GridCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    let titleLabel = UILabel()
    
    let subtitleLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.9, y: 0.9): .identity
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.textColor = .label
        
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render(album: Album) {
        let url = Context.coverArtURL(album: album)
        imageView.kf.setImage(with: url)
        titleLabel.text = album.name
        subtitleLabel.text = album.artist
    }
    
    func render(artist: Artist, client: SubsonicClient) {
        
    }
}
