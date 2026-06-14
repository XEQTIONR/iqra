//
//  CourseImage.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-09.
//

import SwiftUI
import AVKit
import AVFoundation

struct CourseIntroVideoForm: View {
    @Binding var formData: Course
    var onComplete: ((_ course: Course) -> Void)? = nil
    @State private var showPicker = false
    @State private var selectedVideoURL: URL?
    
    
    // video stuff
    @StateObject private var playerManager = PlayerManager()
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    
    
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

    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    if let videoURL = selectedVideoURL {
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
                            playerManager.setupPlayerWithUrl(videoURL) // Replace with your URL
                            setupTimeObserver()
                        }
                        .onDisappear {
                            playerManager.cleanup()
                        }
                    } else {
                        Image(systemName: "video.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 50)
                    }
                    
                    if selectedVideoURL == nil {
                        Button("Select Media") {
                            showPicker = true
                        }
                    } else {
                        Button("Save") {
                            
                        }
                        
                        Button("Clear Image", role: .destructive) {
                            selectedVideoURL = nil
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            CourseBannerForm(
                                formData: $formData,
                                videoUrl: $selectedVideoURL,
                                onComplete: onComplete
                            )
                        } label: {
                            HStack {
                                Image(systemName: "chevron.right")
                                    .padding(.leading)
                                    .opacity(0)
                                Spacer()
                                Text("Continue")
                                    .padding(.all, 10)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing)
                            }
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .navigationTitle("Intro video")
        }
        .sheet(isPresented: $showPicker) {
            MediaPicker(video: $selectedVideoURL)
        }
        
    }
}

#Preview {
    CourseIntroVideoForm(
        formData: .constant(Course(
            title: "Test",
            description: "The description of this course",
            image: "",
            video: "",
            difficulty: .advanced,
            category: .reading,
            lengthType: .fixed,
            ageGroups: [.kids, .teens]
        )),
        onComplete: nil
    )
}
