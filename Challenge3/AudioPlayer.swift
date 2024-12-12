//
//  AudioPlayer.swift
//  Challenge3
//
//  Created by Mathew Blanc on 11/12/24.
//

import Foundation
import SwiftUI
import AVFoundation

class AudioPlayer: ObservableObject {
    var bgMusic: AVAudioPlayer?
    var currentMusic: String = "hymn"
    @Published var isPlaying: Bool = false
    
    func playPauseAudio() {
        let path = Bundle.main.path(forResource: currentMusic, ofType: ".mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            bgMusic = try AVAudioPlayer(contentsOf: url)
            if isPlaying {
                bgMusic?.pause()
            } else {
                bgMusic?.play()
            }
            withAnimation {
                isPlaying.toggle()
            }
        } catch {
            print("Couldn't load file")
        }
    }
    
    func setMusic(_ fileName: String) {
        self.currentMusic = fileName
        
        let path = Bundle.main.path(forResource: currentMusic, ofType: ".mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
            bgMusic?.play()
            withAnimation {
                isPlaying = true
            }
        } catch {
            print("Couldn't load file")
        }
    }
}
