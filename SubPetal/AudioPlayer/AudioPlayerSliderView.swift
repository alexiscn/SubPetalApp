//
//  AudioPlayerSliderView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import ZFPlayer

class AudioPlayerSliderView: UIView {
    
    lazy var sliderView: ZFSliderView = {
        let slider = ZFSliderView()
        slider.allowTapped = true
        slider.sliderHeight = 2
        slider.maximumTrackTintColor = .quaternaryLabel
        slider.minimumTrackTintColor = .label
        let thumbImage = UIImage(named: "icon_slider_12x12_")?.withTintColor(UIColor.label)
        slider.setThumbImage(thumbImage, for: .normal)
        return slider
    }()
    
    let timeLabel = UILabel()
    
    let durationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sliderView)
        addSubview(timeLabel)
        addSubview(durationLabel)
        
        timeLabel.textColor = .secondaryLabel
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        
        durationLabel.textColor = .secondaryLabel
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textAlignment = .right
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            sliderView.topAnchor.constraint(equalTo: self.topAnchor),
            sliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            sliderView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            durationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            durationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
}
