//
//  ArtistProfileHeaderCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/4.
//

import UIKit
import Kingfisher
import SubsonicKit

class ArtistProfileHeaderCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    let titleLabel = UILabel()
    
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = .white
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        gradientLayer.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor(white: 0.5, alpha: 0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        imageView.layer.addSublayer(gradientLayer)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        gradientLayer.frame = CGRect(x: 0, y: bounds.height - 80, width: bounds.width, height: 80)
    }
    
    func render(_ artist: Artist) {
        titleLabel.text = artist.name
        if let id = artist.coverArt {
            let url = Context.current?.client.getCoverArt(id: id)
            imageView.kf.setImage(with: url)
        }
    }
    
}
