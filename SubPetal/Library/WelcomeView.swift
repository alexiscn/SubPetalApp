//
//  WelcomeView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/16.
//

import UIKit

class WelcomeView: UIView {
    
    let stackView = UIStackView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let addButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = UIImage(named: "logo_120x120_")
        
        titleLabel.text = "Welcome to SubPetal"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        
        descLabel.textColor = .secondaryLabel
        descLabel.text = "Streaming Subsonic/Navidrome audios"
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Connect"
        addButton.configuration = configuration
        
        stackView.axis = .vertical
        stackView.spacing = traitCollection.verticalSizeClass == .regular ? 30 : 10
        stackView.alignment = .center
        addSubview(stackView)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(addButton)
        
        stackView.setCustomSpacing(5, after: titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
