//
//  BasicPlayerView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-08.
//
import SwiftUI
import AVKit
import AVFoundation

struct BasicPlayerView: View {
    @StateObject private var playerManager = PlayerManager()
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Video Player View
            VideoPlayer(player: playerManager.player)
                .frame(height: 300)
                .cornerRadius(12)
            
            // Audio Player Controls (for audio-only)
            HStack(spacing: 30) {
                Button(action: { playerManager.seekBackward() }) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                }
                
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                }
                
                Button(action: { playerManager.seekForward() }) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                }
            }
            
            // Progress Slider
            VStack {
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        playerManager.seek(to: currentTime)
                    }
                })
                .accentColor(.blue)
                
                HStack {
                    Text(formatTime(currentTime))
                    Spacer()
                    Text(formatTime(duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            playerManager.setupPlayer(with: "https://www.papytane.com/mp4/vernet.mp4") // Replace with your URL
            setupTimeObserver()
        }
        .onDisappear {
            playerManager.cleanup()
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            playerManager.pause()
        } else {
            playerManager.play()
        }
        isPlaying.toggle()
    }
    
    private func setupTimeObserver() {
        playerManager.addTimeObserver { time in
            currentTime = time
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}



#Preview {
    BasicPlayerView()
}
