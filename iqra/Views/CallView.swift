//
//  CallView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-10.
//
import SwiftUI
import WebRTC

struct CallView: View {
    @StateObject private var webRTCManager = WebRTCManager()
    @State private var userId = ""
    @State private var targetUserId = ""
    @State private var isConnected = false
    
    var body: some View {
        VStack(spacing: 20) {
            if !isConnected {
                TextField("Your User ID", text: $userId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                Button("Connect") {
                    webRTCManager.connect(userId: userId)
                    isConnected = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                // Local video preview
                if let localTrack = webRTCManager.localVideoTrack {
                    VideoView(videoTrack: localTrack)
                        .frame(height: 200)
                        .border(Color.gray)
                        .cornerRadius(8)
                }
                
                // Remote video
                if let remoteTrack = webRTCManager.remoteVideoTrack {
                    VideoView(videoTrack: remoteTrack)
                        .frame(height: 400)
                        .border(Color.gray)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 400)
                        .overlay(Text("Waiting for remote video..."))
                        .cornerRadius(8)
                }
                
                TextField("Call User ID", text: $targetUserId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                HStack(spacing: 20) {
                    Button("Start Call") {
                        webRTCManager.startCall(to: targetUserId)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(targetUserId.isEmpty)
                    
                    Button("Hang Up") {
                        webRTCManager.hangUp()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}

// Video rendering view
struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView(frame: .zero)
        videoView.videoContentMode = .scaleAspectFill
        return videoView
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        videoTrack.add(uiView)
    }
}

#Preview {
    CallView()
}

