//
//  AudioPlayerControlView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit

protocol AudioPlayerControlViewDelegate: AnyObject {
    func controlViewPreviousAction()
    func controlViewPlayPauseAction()
    func controlViewNextAction()
}

class AudioPlayerControlView: UIView {
    
    weak var delegate: AudioPlayerControlViewDelegate?
    
    let previousButton: UIButton
    
    let playPauseButton: UIButton
    
    let bufferingView = UIActivityIndicatorView(style: .large)
    
    let nextButton: UIButton
    
    override init(frame: CGRect) {
        previousButton = UIButton(type: .system)
        previousButton.tintColor = .label
        previousButton.setImage(UIImage(systemName: "backward.end.alt.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18))), for: [])
        
        playPauseButton = UIButton(type: .custom)
        playPauseButton.tintColor = .label
        playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 44))), for: .normal)
        playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 44))), for: .selected)
        playPauseButton.setImage(UIImage(), for: .disabled)
        
        nextButton = UIButton(type: .system)
        nextButton.tintColor = .label
        nextButton.setImage(UIImage(systemName: "forward.end.alt.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18))), for: [])
        
        super.init(frame: frame)
        
        playPauseButton.addSubview(bufferingView)
        addSubview(previousButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        
        setupConstrants()
        
        previousButton.addTarget(self, action: #selector(onPreviousButtonClicked), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(onPlayPauseButtonClicked), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(onNextButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrants() {
        
        bufferingView.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            bufferingView.centerXAnchor.constraint(equalTo: playPauseButton.centerXAnchor),
            bufferingView.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 60),
            previousButton.heightAnchor.constraint(equalTo: heightAnchor),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            previousButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -120),
            
            playPauseButton.heightAnchor.constraint(equalTo: heightAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 80),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 60),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 120),
        ])
    }
    
    @objc private func onPreviousButtonClicked() {
        delegate?.controlViewPreviousAction()
    }
    
    @objc private func onPlayPauseButtonClicked() {
        delegate?.controlViewPlayPauseAction()
    }
    
    @objc private func onNextButtonClicked() {
        delegate?.controlViewNextAction()
    }
}
