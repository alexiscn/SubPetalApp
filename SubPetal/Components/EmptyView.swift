//
//  EmptyView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/12.
//

import UIKit

class EmptyView: UIStackView {
    
    let imageView = UIImageView()
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 20
        
        imageView.tintColor = .quaternaryLabel
        
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
