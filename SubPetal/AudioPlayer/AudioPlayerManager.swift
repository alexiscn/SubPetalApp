//
//  AudioPlayerManager.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/3.
//

import Foundation
import AVFoundation
import AudioStreaming
import SubsonicKit
import MediaPlayer
import Defaults
import Kingfisher

protocol AudioPlayerManagerDelegate: AnyObject {
    func audioPlayerDidStartPlaying()
    func audioPlayerDidStopPlaying()
    func audioPlayerStatusChanged(state: AudioPlayerState)
    func audioPlayerErrorOccurred(error: AudioPlayerError)
    func audioPlayerMetadataReceived(metadata: [String: String])
    func audioPlayerTimeChanged(time: TimeInterval, duration: TimeInterval)
}

class AudioPlayerManager: NSObject {
    
    static let shared = AudioPlayerManager()
    
    var delegate = MulticastDelegate<AudioPlayerManagerDelegate>()
    
    var isPlaying: Bool { return player.state == .playing }
    
    var count: Int { return queue.songs.count }
    
    var duration: TimeInterval { return player.duration }
    
    var currentTime: TimeInterval { return player.progress }
    
    private var player: AudioPlayer
    private var audioSystemResetObserver: Any?
    private(set) var queue = AudioQueue()
    private var displayLink: CADisplayLink?
    
    var repeatMode: AudioRepeatMode {
        get { return Defaults[.repeatMode] }
        set { Defaults[.repeatMode] = newValue }
    }
    
    var playingSong: Song? {
        get { return queue.current }
    }
    var artwork: UIImage?
    
    private override init() {
        player = AudioPlayer()
        super.init()
        loadQueue()
        player.delegate = self
        registerSessionEvents()
        configureAudioSession()
        subscripeRemoteCommands()
    }
}

// MARK: - Playback
extension AudioPlayerManager {
    
    func pause() {
        player.pause()
    }
    
    func resume() {
        player.resume()
    }
    
    func toggle() {
        if player.state == .ready,
            let song = playingSong,
            let index = queue.songs.firstIndex(where: { $0.id == song.id }) {
            play(queue.songs, at: index)
        } else {
            isPlaying ? pause(): resume()
        }
    }
    
    func stop() {
        player.stop()
        deactivateAudioSession()
    }
    
    private func stream(_ song: Song) {
        if let localURL = Context.current?.streamCache.cacheFileURL(for: song),
            FileManager.default.fileExists(atPath: localURL.path) {
            player.play(url: localURL)
        } else if let url = Context.current?.client.stream(id: song.id) {
            player.play(url: url)
            saveQueue()
        }
    }
    
    func play(_ song: Song) {
        if let index = queue.songs.firstIndex(where: { $0.id == song.id }) {
            queue.currentIndex = index
            stream(song)
        } else {
            play([song], at: 0)
        }
    }
    
    func play(_ songs: [Song], at index: Int) {
        var current = 0
        if index >= 0 && index < songs.count {
            current = index
        }
        queue.songs = songs
        queue.currentIndex = current
        
        let song = songs[current]
        stream(song)
    }
    
    func append(_ songs: [Song]) {
        
    }
    
    func remove(song: Song) {
        
    }
    
    func skipNext() {
        if let song = queue.next {
            stream(song)
        }
    }
    
    func skipPrevious() {
        if let song = queue.previous {
            stream(song)
        }
    }
    
    func seek(to time: TimeInterval) {
        player.seek(to: time)
    }
}

// MARK: - Queue
extension AudioPlayerManager {
    
    private var queueFileURL: URL {
        let basePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let path = basePath.appending("/playingQueue.json")
        return URL(fileURLWithPath: path)
    }
    
    private func loadQueue() {
        guard FileManager.default.fileExists(atPath: queueFileURL.path) else {
            return
        }
        do {
            let data = try Data(contentsOf: queueFileURL)
            let lastQueue = try JSONDecoder().decode(AudioQueue.self, from: data)
            self.queue = lastQueue
        } catch {
            print(error)
        }
    }
    
    private func saveQueue() {
        do {
            let data = try JSONEncoder().encode(queue)
            try data.write(to: queueFileURL)
        } catch {
            print(error)
        }
    }
}

// MARK: - DisplayLink
extension AudioPlayerManager {
 
    private func startDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(tick))
        displayLink?.preferredFramesPerSecond = 6
        displayLink?.add(to: .current, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick() {
        if duration > 0 {
            delegate.invoke(invocation: { $0.audioPlayerTimeChanged(time: currentTime, duration: duration) })
        }
    }
}

// MARK: - AudioPlayerDelegate
extension AudioPlayerManager: AudioPlayerDelegate {
    
    func audioPlayerDidStartPlaying(player: AudioPlayer, with entryId: AudioEntryId) {
        startDisplayLink()
        delegate.invoke(invocation: { $0.audioPlayerDidStartPlaying() })
        NowPlayingCenter.song = playingSong
        NowPlayingCenter.update()
    }
    
    func audioPlayerDidFinishBuffering(player: AudioPlayer, with entryId: AudioEntryId) {

    }
    
    func audioPlayerStateChanged(player: AudioPlayer, with newState: AudioPlayerState, previous: AudioPlayerState) {
        delegate.invoke(invocation: { $0.audioPlayerStatusChanged(state: newState) })
        NowPlayingCenter.update()
    }
    
    func audioPlayerDidFinishPlaying(player: AudioPlayer, entryId: AudioEntryId, stopReason: AudioPlayerStopReason, progress: Double, duration: Double) {
        delegate.invoke(invocation: { $0.audioPlayerDidStopPlaying() })
        stopDisplayLink()
        if duration - progress < 0.5 {
            skipNext()
        }
    }
    
    func audioPlayerUnexpectedError(player: AudioPlayer, error: AudioPlayerError) {
        delegate.invoke(invocation: { $0.audioPlayerErrorOccurred(error: error) })
    }
    
    func audioPlayerDidCancel(player: AudioPlayer, queuedItems: [AudioEntryId]) {
        
    }
    
    func audioPlayerDidReadMetadata(player: AudioPlayer, metadata: [String : String]) {
        delegate.invoke(invocation: { $0.audioPlayerMetadataReceived(metadata: metadata) })
    }
}

// MARK: - AudioSession
extension AudioPlayerManager {
    
    private func registerSessionEvents() {
        // Note that a real app might need to observer other AVAudioSession notifications as well
        audioSystemResetObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification,
                                                                          object: nil,
                                                                          queue: nil) { [unowned self] _ in
            self.configureAudioSession()
            self.recreatePlayer()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        switch type {
        case .began:
            player.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
                player.resume()
            } else {
                // An interruption ended. Don't resume playback.
            }
        default: ()
        }
    }
    
    @objc private func handleAudioSessionRouteChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        // Switch over the route change reason.
        switch reason {
        case .newDeviceAvailable: // New device found.
            let session = AVAudioSession.sharedInstance()
            let headphonesConnected = hasHeadphones(in: session.currentRoute)
            if headphonesConnected {
                resume()
            }
        case .oldDeviceUnavailable: // Old device removed.
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                let headphonesConnected = hasHeadphones(in: previousRoute)
                if !headphonesConnected {
                    pause()
                }
            }
        default: ()
        }
    }
    
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    
    private func recreatePlayer() {
        player = AudioPlayer()
        player.delegate = self
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.1)
        } catch let error as NSError {
            print("Couldn't setup audio session category to Playback \(error.localizedDescription)")
        }
    }

    private func activateAudioSession() {
        do {
            print("AudioSession is active")
            try AVAudioSession.sharedInstance().setActive(true, options: [])

        } catch let error as NSError {
            print("Couldn't set audio session to active: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        do {
            print("AudioSession is deactivated")
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("Couldn't deactivate audio session: \(error.localizedDescription)")
        }
    }
    
}

// MARK: RemoteControl
extension AudioPlayerManager {
    
    func subscripeRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.togglePlayPauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pause()
            } else {
                self.resume()
            }
            return .success
        }
        center.playCommand.addTarget { [unowned self] event in
            if !self.isPlaying {
                self.resume()
                return .success
            }
            return .commandFailed
        }
        center.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        center.nextTrackCommand.addTarget { [unowned self] event in
            self.skipNext()
            return .success
        }
        
        center.previousTrackCommand.addTarget { [unowned self] event in
            self.skipPrevious()
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [unowned self] event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(to: positionEvent.positionTime)
            }
            return .success
        }
    }
    
}
