//
//  AudioPlayerViewController.swift
//  SubPetal
//
//  Created by alexiscn on 2022/5/31.
//

import UIKit
import Kingfisher
import ZFPlayer
import SubsonicKit
import Defaults
import AudioStreaming

class AudioPlayerViewController: UIViewController {
    
    private var moreItem: UIBarButtonItem!
    private let backgroundImageView = UIImageView()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var artworkView: AudioPlayerArtworkView!
    private var contentView: AudioPlayerContentView!
    private var controlView: AudioPlayerControlView!
    private var sliderView: AudioPlayerSliderView!
    private let actionView = AudioPlayerActionView()
    
    private var artworkWidthConstraint: NSLayoutConstraint!
    private var artworkHeightConstraint: NSLayoutConstraint!
    private var artworkLeadingConstraint: NSLayoutConstraint!
    private var artworkTopConstranit: NSLayoutConstraint!
    private var titleLeadingConstraint: NSLayoutConstraint!
    private var titleCenterYConstrant: NSLayoutConstraint!
    private var contentViewTopConstraint: NSLayoutConstraint!
    
    private var slider: ZFSliderView {
        return sliderView.sliderView
    }
    
    private var isSmallScreen: Bool {
        return UIScreen.main.bounds.width <= 375
    }
    
    private var coverSize: CGFloat {
        return isSmallScreen ? 250.0: 300.0
    }
    
    private var coverTop: CGFloat {
        return isSmallScreen ? 44.0: 84.0
    }
    
    private var actionBottom: CGFloat {
        return isSmallScreen ? 18: 28
    }
    
    private var controlHeight: CGFloat {
        return isSmallScreen ? 44: 80
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupBackgroundView()
        setupSubviews()
        
        AudioPlayerManager.shared.delegate.add(delegate: self)
        if let song = AudioPlayerManager.shared.playingSong {
            updatePlayingSong(song)
        }
    }
    
    deinit {
        AudioPlayerManager.shared.delegate.remove(delegate: self)
    }
    
}

extension AudioPlayerViewController {
    
    private func setupNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let closeItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(onCloseItemClicked))
        navigationItem.leftBarButtonItem = closeItem
        
        moreItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: makeMoreMenu())
        navigationItem.rightBarButtonItem = moreItem
    }
    
    private func setupBackgroundView() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        
        effectView.frame = view.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(effectView)
    }
    
    private func setupSubviews() {
        artworkView = AudioPlayerArtworkView()
        view.addSubview(artworkView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)
        
        contentView = AudioPlayerContentView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 80, height: 180))
        contentView.alpha = 0
        view.addSubview(contentView)
        
        controlView = AudioPlayerControlView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        controlView.delegate = self
        view.addSubview(controlView)
        
        sliderView = AudioPlayerSliderView(frame: .zero)
        sliderView.sliderView.delegate = self
        view.addSubview(sliderView)
        
        actionView.delegate = self
        view.addSubview(actionView)
        
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        controlView.translatesAutoresizingMaskIntoConstraints = false
        actionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        artworkWidthConstraint = artworkView.widthAnchor.constraint(equalToConstant: coverSize)
        artworkHeightConstraint = artworkView.heightAnchor.constraint(equalToConstant: coverSize)
        let coverX = (view.bounds.width - coverSize)/2.0
        artworkLeadingConstraint = artworkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: coverX)
        artworkTopConstranit = artworkView.topAnchor.constraint(equalTo: view.topAnchor, constant: coverTop)
        
        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        titleCenterYConstrant = titleLabel.centerYAnchor.constraint(equalTo: artworkView.centerYAnchor, constant: 180)
        contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 30)
        NSLayoutConstraint.activate([
            artworkWidthConstraint,
            artworkHeightConstraint,
            artworkLeadingConstraint,
            artworkTopConstranit,
            titleLeadingConstraint,
            titleCenterYConstrant,
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentViewTopConstraint,
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
            contentView.bottomAnchor.constraint(equalTo: sliderView.topAnchor, constant: -30),
            
            sliderView.heightAnchor.constraint(equalToConstant: 44),
            sliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            sliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            sliderView.bottomAnchor.constraint(equalTo: controlView.topAnchor, constant: -30),
            
            controlView.widthAnchor.constraint(equalTo: view.widthAnchor),
            controlView.heightAnchor.constraint(equalToConstant: controlHeight),
            controlView.bottomAnchor.constraint(equalTo: actionView.topAnchor, constant: -20),
            
            actionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            actionView.heightAnchor.constraint(equalToConstant: 40),
            actionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -actionBottom)
        ])
    }
        
}

// MARK: - Event
extension AudioPlayerViewController {
    
    @objc private func onCloseItemClicked() {
        presentingViewController?.dismiss(animated: true)
    }
    
}

// MARK: - Menu
extension AudioPlayerViewController {
    
    private func makeMoreMenu() -> UIMenu {
        var children = [UIMenuElement]()
        
        if let song = AudioPlayerManager.shared.playingSong {
            let similarSongsAction = UIAction(title: "Similar Songs") { [unowned self] _ in
                similarSongs(with: song)
            }
            similarSongsAction.image = UIImage(systemName: "mail.stack")
            children.append(similarSongsAction)
            
            if song.starred != nil {
                let unstarAction = UIAction(title: "Unstar") { [unowned self] _ in
                    unstar(song: song)
                }
                unstarAction.image = UIImage(systemName: "heart.fill")
                children.append(unstarAction)
            } else {
                let starAction = UIAction(title: "Star") { [unowned self] _ in
                    star(song: song)
                }
                starAction.image = UIImage(systemName: "heart")
                children.append(starAction)
            }
            
            if let artist = song.artist, let id = song.artistId {
                let artistAction = UIAction(title: artist) { [unowned self] _ in
                    showArtistProfile(id: id)
                }
                artistAction.image = UIImage(systemName: "person.circle.fill")
                children.append(artistAction)
            }
            
            if let album = song.album, let id = song.albumId {
                let albumAction = UIAction(title: album) { [unowned self] _ in
                    showAlbumProfile(id: id)
                }
                albumAction.image = UIImage(systemName: "rectangle.stack.fill")
                children.append(albumAction)
            }
        }
        
        
        if let infoMenu = makeInfoMenu() {
            children.append(infoMenu)
        }
        
        return UIMenu(children: children)
    }
    
    private func makeInfoMenu() -> UIMenu? {
        guard let song = AudioPlayerManager.shared.playingSong else {
            return nil
        }
        var children = [UIAction]()
        if let suffix = song.suffix {
            let formatAction = UIAction(title: "Format", subtitle: suffix.uppercased()) { _ in}
            children.append(formatAction)
        }
        if let bitRate = song.bitRate {
            let bitRateAction = UIAction(title: "BitRate", subtitle: "\(bitRate) kbps") { _ in }
            children.append(bitRateAction)
        }
        if let size = song.size {
            let sizeInfo = ByteCountFormatter().string(fromByteCount: size)
            let sizeAction = UIAction(title: "Size", subtitle: sizeInfo) { _ in }
            children.append(sizeAction)
        }
        
        return UIMenu(title: "Info", children: children)
    }
    
    private func star(song: Song) {
        Task {
            do {
                try await Context.current?.client.star(id: song.id)
                song.starred = ISO3601DateFormatter.shared.string(from: Date())
                moreItem.menu = makeMoreMenu()
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
    
    private func unstar(song: Song) {
        Task {
            do {
                try await Context.current?.client.unstar(id: song.id)
                song.starred = nil
                moreItem.menu = makeMoreMenu()
            } catch {
                HUD.show(error: error.localizedDescription)
            }
        }
    }
    
    private func similarSongs(with song: Song) {
        let vc = SimilarSongsViewController(song: song)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func showAlbumProfile(id: String) {
        Task {
            do {
                if let album = try await Context.current?.client.getAlbum(id: id).album {
                    let vc = AlbumProfileViewController(album: album)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func showArtistProfile(id: String) {
        Task {
            do {
                if let artist = try await Context.current?.client.getArtist(id: id).artist {
                    let vc = ArtistProfileViewController(artist: artist)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: -
extension AudioPlayerViewController {
    
    private func updatePlayingSong(_ song: Song) {
        let url = Context.coverArtURL(song: song)
        backgroundImageView.kf.setImage(with: url)
        artworkView.imageView.kf.setImage(with: url, placeholder: UIImage(named: "music_cover_300x300_"))
        titleLabel.text = song.title
        subtitleLabel.text = song.artist
        
        sliderView.timeLabel.text = Formatter.format(AudioPlayerManager.shared.currentTime)
        if AudioPlayerManager.shared.duration == 0, let duration = song.duration {
            sliderView.durationLabel.text = Formatter.format(TimeInterval(duration))
        } else {
            sliderView.durationLabel.text = Formatter.format(AudioPlayerManager.shared.duration)
        }
        contentView.playlistView.select(song: song)
        contentView.fetchLyrics(for: song)
        controlView.playPauseButton.isSelected = AudioPlayerManager.shared.isPlaying
    }
    
    private func switchToPlaylistMode() {
        
        if actionView.playlistButton.isSelected {
            showContentView(true, content: .playlist)
            switchCoverToDefault(false)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                
            }
        } else {
            showContentView(false, content: .playlist)
            switchCoverToDefault(true)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                
            }
        }
    }
    
    private func switchToLyricsMode() {
        if actionView.lyricButton.isSelected {
            showContentView(true, content: .lyrics)
            switchCoverToDefault(false)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                
            }
        } else {
            showContentView(false, content: .lyrics)
            switchCoverToDefault(true)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                
            }
        }
    }
    
    private func switchCoverToDefault(_ toDefault: Bool) {
        artworkWidthConstraint.constant = toDefault ? coverSize : 80
        artworkHeightConstraint.constant = toDefault ? coverSize : 80
        artworkLeadingConstraint.constant = toDefault ? (view.bounds.width - coverSize)/2.0 : 40
        artworkTopConstranit.constant = toDefault ? coverTop: 44
        
        titleLeadingConstraint.constant = toDefault ? 30: 140
        titleCenterYConstrant.constant = toDefault ? 180: -10
    }
    
    private func showContentView(_ show: Bool, content: AudioPlayerContentView.Content) {
        if show {
            contentView.alpha = 1
            contentView.show(content: content)
        } else {
            contentView.hide()
            UIView.animate(withDuration: 0.25) {
                self.contentView.alpha = 0
            }
        }
    }
}

// MARK: - AudioPlayerControlViewDelegate
extension AudioPlayerViewController: AudioPlayerControlViewDelegate {
    
    func controlViewPreviousAction() {
        AudioPlayerManager.shared.skipPrevious()
    }
    
    func controlViewPlayPauseAction() {
        AudioPlayerManager.shared.toggle()
    }
    
    func controlViewNextAction() {
        AudioPlayerManager.shared.skipNext()
    }
}

// MARK: - ZFSliderViewDelegate
extension AudioPlayerViewController: ZFSliderViewDelegate {
    
    func sliderTouchBegan(_ value: Float) {
        slider.isdragging = true
    }
    
    func sliderValueChanged(_ value: Float) {
        let duration = AudioPlayerManager.shared.duration
        if duration == 0 {
            slider.value = 0
            UIView.animate(withDuration: 0.25) {
                self.slider.sliderBtn.transform = .identity
            }
            return
        }

        slider.isdragging = true
        let currentTime = TimeInterval(value) * duration
        sliderView.timeLabel.text = Formatter.format(currentTime)
        UIView.animate(withDuration: 0.25) {
            self.slider.sliderBtn.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    func sliderTouchEnded(_ value: Float) {
        let duration = AudioPlayerManager.shared.duration
        if duration > 0 {
            slider.isdragging = true
            AudioPlayerManager.shared.seek(to: duration * Double(value))
            slider.isdragging = false
        } else {
            slider.isdragging = false
            slider.value = 0
            UIView.animate(withDuration: 0.25) {
                self.slider.sliderBtn.transform = .identity
            }
        }
    }
    
    func sliderTapped(_ value: Float) {
        sliderTouchEnded(value)
        let currentTime = TimeInterval(value) * AudioPlayerManager.shared.duration
        sliderView.timeLabel.text = Formatter.format(currentTime)
    }
    
}

// MARK: - AudioPlayerActionViewDelegate
extension AudioPlayerViewController: AudioPlayerActionViewDelegate {
    
    func actionViewLyricsAction() {
        switchToLyricsMode()
    }
    
    func actionViewModeAction() {
        AudioPlayerManager.shared.repeatMode = AudioPlayerManager.shared.repeatMode.next
        actionView.modeButton.setImage(AudioPlayerManager.shared.repeatMode.displayIcon, for: [])
    }
    
    func actionViewPlaylistAction() {
        switchToPlaylistMode()
    }
}

// MARK: - AudioPlayerManagerDelegate
extension AudioPlayerViewController: AudioPlayerManagerDelegate {
    
    func audioPlayerDidStartPlaying() {
        if let song = AudioPlayerManager.shared.playingSong {
            updatePlayingSong(song)
        }
    }
    
    func audioPlayerDidStopPlaying() {
        
    }
    
    func audioPlayerStatusChanged(state: AudioPlayerState) {
        if state == .bufferring {
            controlView.playPauseButton.isEnabled = false
            controlView.bufferingView.startAnimating()
        } else {
            controlView.playPauseButton.isEnabled = true
            controlView.bufferingView.stopAnimating()
            controlView.playPauseButton.isSelected = state == .playing
        }
    }
    
    func audioPlayerErrorOccurred(error: AudioPlayerError) {
        
    }
    
    func audioPlayerMetadataReceived(metadata: [String : String]) {
        
    }
    
    func audioPlayerTimeChanged(time: TimeInterval, duration: TimeInterval) {
        guard duration > 0 else { return }
        if !slider.isdragging {
            slider.value = Float(time/duration)
        }
        sliderView.timeLabel.text = Formatter.format(time)
        sliderView.durationLabel.text = Formatter.format(duration)
        contentView.lyricsView.updatePlaying(currentTime: time)
    }
}
