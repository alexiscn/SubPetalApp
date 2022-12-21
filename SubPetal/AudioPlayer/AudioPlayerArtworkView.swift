//
//  AudioPlayerArtworkView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit

class AudioPlayerArtworkView: UIView {
    
    let imageView = UIImageView()
    
    var image: UIImage? = nil {
        didSet { imageView.image = image }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "music_cover_300x300_")
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        addSubview(imageView)
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 12
        layer.shadowColor = UIColor.secondaryLabel.cgColor
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
