//
//  AudioPlayer.swift
//  DriveFast
//
//  Created by Atilla Özder on 1.05.2020.
//  Copyright © 2020 Atilla Özder. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - AudioPlayer
final class AudioPlayer: NSObject {
    
    static let shared: AudioPlayer = .init()
    
    private var player: AVAudioPlayer?
    private var readyForMusic: Music = .none

    private lazy var queue = DispatchQueue(
        label: "com.atillaozder.DriveFast.serialQueue.audioPlayer", qos: .userInitiated)
    
    var isSoundOn: Bool {
        return UserDefaults.standard.isSoundOn
    }
        
    private override init() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @discardableResult
    func prepare(toPlay music: Music) -> Bool {
        if !isSoundOn {
            return false
        }
        
        guard let url = music.urlRepresentation() else { return false }
        do {
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.numberOfLoops = -1
            player.prepareToPlay()
            self.player = player
            self.readyForMusic = music
            return true
        } catch {
            return false
        }
    }
            
    func playMusic(_ music: Music = .main, withVolume volume: Float = 1) {
        if !isSoundOn {
            return
        }
                
        queue.async {
             if self.readyForMusic == music {
                self.player?.play()
            } else {
                self.prepare(toPlay: music)
                self.player?.volume = volume
                self.player?.play()
            }
        }
    }
    
    func pauseMusic() {
        queue.async {
            guard let player = self.player else { return }
            player.pause()
        }
    }
    
    func stopMusic() {
        queue.async {
            guard let player = self.player else { return }
            player.stop()
        }
    }
}

// MARK: - URLRepresentable
protocol URLRepresentable {
    func urlRepresentation() -> URL?
}

// MARK: - Music
enum Music: Int {
    case none = 0, main
}

extension Music: URLRepresentable {
    func urlRepresentation() -> URL? {
        switch self {
            case .main:
                return Bundle.main.url(forResource: "main", withExtension: ".mp3")
            default:
                return nil
        }
    }
}
