//
//  MusicManager.swift
//  Lucky Eagle Game
//
//  Created by Mac on 28.04.2025.
//

import Foundation
import AVFoundation

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    @Published var audioPlayerVolume: Float = 0.5
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
            audioPlayer?.volume = audioPlayerVolume
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
