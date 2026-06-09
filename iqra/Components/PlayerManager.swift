//
//  PlayerManager.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//
import AVKit
import AVFoundation

// Player Manager with AVPlayer
class PlayerManager: NSObject, ObservableObject {
    var player: AVPlayer?
    private var timeObserver: Any?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    func setupPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        setupPlayerWithUrl(url)
    }
    
    func setupPlayerWithUrl(_ url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player item status
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status),
                              options: [.new, .initial], context: nil)
        
        // Observe duration
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration),
                              options: [.new], context: nil)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    func seekForward() {
        guard let currentTime = player?.currentTime().seconds else { return }
        seek(to: currentTime + 10)
    }
    
    func seekBackward() {
        guard let currentTime = player?.currentTime().seconds else { return }
        seek(to: currentTime - 10)
    }
    
    func addTimeObserver(update: @escaping (TimeInterval) -> Void) {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            update(time.seconds)
        }
    }
    
    func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let item = object as? AVPlayerItem {
                switch item.status {
                case .readyToPlay:
                    print("Ready to play")
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                case .failed:
                    print("Failed to load: \(item.error?.localizedDescription ?? "Unknown error")")
                case .unknown:
                    print("Unknown status")
                @unknown default:
                    break
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.duration) {
            if let item = object as? AVPlayerItem, item.duration.seconds.isFinite {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }
}
