//
//  PaletteVisualEffectView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit

class PaletteVisualEffectView: UIView {
    
    private lazy var nowPlayingBarViewcontroller = NowPlayingBarViewController()
    
    private let effectView: UIVisualEffectView
    
    private var nowPlayingBarTopConstraint: NSLayoutConstraint!
    
    var isNowPlayingBarHidden = true
    
    override init(frame: CGRect) {
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        effectView = UIVisualEffectView(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.init(frame: frame)
        
        addSubview(effectView)
        
        effectView.contentView.addSubview(nowPlayingBarViewcontroller.view)
        nowPlayingBarViewcontroller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nowPlayingBarViewcontroller.view.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor),
            nowPlayingBarViewcontroller.view.widthAnchor.constraint(equalTo: effectView.contentView.widthAnchor),
            nowPlayingBarViewcontroller.view.heightAnchor.constraint(equalTo: effectView.contentView.heightAnchor)
        ])
        nowPlayingBarTopConstraint = nowPlayingBarViewcontroller.view.topAnchor.constraint(equalTo: effectView.contentView.topAnchor)
        nowPlayingBarTopConstraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
    }
    
    func hideNowPlayingBar() {
        
        UIView.animate(withDuration: 0.2) {
            self.nowPlayingBarTopConstraint.constant = self.bounds.height
            self.setNeedsLayout()
        } completion: { _ in
            self.isHidden = true
            self.isNowPlayingBarHidden = true
        }

    }
    
    func showNowPlayingBar() {
        self.isHidden = false
        self.isNowPlayingBarHidden = false
        UIView.animate(withDuration: 0.2) {
            self.nowPlayingBarTopConstraint.constant = 0
            self.setNeedsLayout()
        }
    }
    
}
