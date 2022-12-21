//
//  NowPlayingBarViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import UIKit
import SubsonicKit
import Kingfisher
import AudioStreaming

class NowPlayingBarViewController: UIViewController {
    
    static let progressHeight: CGFloat = 2
    static let barHeight: CGFloat = 56 + progressHeight
    
    private var containerView: UIView!
    private var imageView: UIImageView!
    private var controlStack: UIStackView!
    private var playButton: UIButton!
    private var bufferingView = UIActivityIndicatorView(style: .medium)
    private var nextButton: UIButton!
    private var progressView: UIProgressView!
    private let notPlayingLabel = UILabel()
    private let songStack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupTapGesture()
        
        AudioPlayerManager.shared.delegate.add(delegate: self)
        if let song = AudioPlayerManager.shared.playingSong {
            updateNowPlayingSong(song)
        }
        notPlayingLabel.isHidden = !AudioPlayerManager.shared.queue.songs.isEmpty
    }
    
    func updateNowPlayingSong(_ song: Song) {
        let url = Context.coverArtURL(song: song)
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "icon_now_playing_cover_56x56_"))
        titleLabel.text = song.title
        notPlayingLabel.isHidden = true
        var subtitles = [String]()
        if let artist = song.artist {
            subtitles.append(artist)
        }
        if let album = song.album {
            subtitles.append(album)
        }
        subtitleLabel.text = subtitles.joined(separator: " - ")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.backgroundColor = UIColor(white: 0, alpha: 0.15)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.backgroundColor = UIColor(white: 0, alpha: 0)
    }
}

// MARK: - Setup
extension NowPlayingBarViewController {
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        
        containerView = UIView()
        view.addSubview(containerView)
        
        progressView = UIProgressView()
        progressView.trackTintColor = .systemBackground
        containerView.addSubview(progressView)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_now_playing_cover_56x56_")
        containerView.addSubview(imageView)
        
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        
        songStack.spacing = 3
        songStack.axis = .vertical
        songStack.distribution = .fill
        songStack.addArrangedSubview(titleLabel)
        songStack.addArrangedSubview(subtitleLabel)
        containerView.addSubview(songStack)
        
        notPlayingLabel.text = "Not Playing"
        notPlayingLabel.textColor = .label
        containerView.addSubview(notPlayingLabel)
        
        playButton = UIButton(type: .custom)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        playButton.setImage(UIImage(), for: .disabled)
        playButton.addTarget(self, action: #selector(onPlayPauseButtonClicked), for: .touchUpInside)
        playButton.tintColor = .label
        playButton.addSubview(bufferingView)
        
        nextButton = UIButton(type: .custom)
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextButton.tintColor = .label
        nextButton.addTarget(self, action: #selector(onNextButtonClicked), for: .touchUpInside)
        
        controlStack = UIStackView(arrangedSubviews: [playButton, nextButton])
        controlStack.axis = .horizontal
        controlStack.distribution = .fill
        containerView.addSubview(controlStack)
    }
    
    private func setupConstraints() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: NowPlayingBarViewController.barHeight)
        ])
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: containerView.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: NowPlayingBarViewController.progressHeight)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: NowPlayingBarViewController.progressHeight)
        ])
        
        songStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            songStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            songStack.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        notPlayingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notPlayingLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            notPlayingLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8)
        ])
        
        bufferingView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bufferingView.centerXAnchor.constraint(equalTo: playButton.centerXAnchor),
            bufferingView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlStack.leadingAnchor.constraint(equalTo: songStack.trailingAnchor, constant: 10),
            controlStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            controlStack.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            controlStack.widthAnchor.constraint(equalToConstant: 88)
        ])
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onNowPlayingBarTapped))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func onNowPlayingBarTapped() {
        let vc = AudioPlayerViewController()
        let nav = UINavigationController(rootViewController: vc)
        UIApplication.topViewController?.present(nav, animated: true, completion: nil)
        view.backgroundColor = UIColor(white: 0, alpha: 0)
    }
}

// MARK: - AudioPlayerManagerDelegate
extension NowPlayingBarViewController: AudioPlayerManagerDelegate {
    
    func audioPlayerDidStartPlaying() {
        if let song = AudioPlayerManager.shared.playingSong {
            updateNowPlayingSong(song)
        }
    }
    
    func audioPlayerDidStopPlaying() {
        
    }
    
    func audioPlayerStatusChanged(state: AudioPlayerState) {
        if state == .bufferring {
            playButton.isEnabled = false
            playButton.isSelected = false
            bufferingView.startAnimating()
        } else {
            bufferingView.stopAnimating()
            playButton.isEnabled = true
            playButton.isSelected = state == .playing
        }
    }
    
    func audioPlayerErrorOccurred(error: AudioPlayerError) {
        
    }
    
    func audioPlayerMetadataReceived(metadata: [String : String]) {
        
    }
    
    func audioPlayerTimeChanged(time: TimeInterval, duration: TimeInterval) {
        guard duration > 0 else { return }
        progressView.progress = Float(time/duration)
    }
}

// MARK: - Button Events
extension NowPlayingBarViewController {
    
    @objc private func onPlayPauseButtonClicked() {
        AudioPlayerManager.shared.toggle()
    }
    
    @objc private func onNextButtonClicked() {
        AudioPlayerManager.shared.skipNext()
    }
}
