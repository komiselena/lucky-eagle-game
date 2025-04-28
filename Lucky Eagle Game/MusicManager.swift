//
//  MusicManager.swift
//  Lucky Eagle Game
//
//  Created by Mac on 28.04.2025.
//

import Foundation
import AVFoundation

class MusicManager {
    static let shared = MusicManager()
    
    var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "535631__williecombs__ghost-house", withExtension: "wav") else {
            print("Music file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.5    
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
    }
    
    func pauseMusic() {
        audioPlayer?.pause()
    }
    
    func resumeMusic() {
        audioPlayer?.play()
    }
}
