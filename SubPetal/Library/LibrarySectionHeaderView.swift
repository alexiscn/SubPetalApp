//
//  LibrarySectionHeaderView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/1.
//

import UIKit

class LibrarySectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "LibrarySectionHeaderView"
    
    var actionHandler: (() -> Void)?
    
    let textLabel = UILabel()
    let actionButton = UIButton(type: .system)
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textLabel.textColor = .label
        
        actionButton.setTitleColor(.secondaryLabel, for: [])
        
        addSubview(textLabel)
        addSubview(actionButton)
        addSubview(activityIndicator)
        
        actionButton.addTarget(self, action: #selector(onActionButtonClicked), for: .touchUpInside)
        
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = ""
        actionButton.setTitle(nil, for: [])
    }
    
    private func setupConstraints() {
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            textLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12)
        ])
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor)
        ])
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTitleLabelTapped))
        textLabel.isUserInteractionEnabled = true
        textLabel.addGestureRecognizer(tap)
    }
    
    @objc private func onTitleLabelTapped() {
        actionHandler?()
    }
    
    @objc private func onActionButtonClicked() {
        actionHandler?()
    }
    
    func render(title: String?, actionText: String? = nil) {
        textLabel.text = title
        actionButton.setTitle(actionText, for: [])
        actionButton.isHidden = actionText == nil
    }
}

