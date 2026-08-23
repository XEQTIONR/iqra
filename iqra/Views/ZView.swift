//
//  ZView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-17.
//

import SwiftUI

struct ZView: View {
    
    @Environment(User.self) private var appUser
    @StateObject private var webRTCManager = WebRTCManager()
    
    //@State private var userId: String
    //@State private var targetUserId: String
    @State private var isConnected = false
    
    @State private var orangePosition = CGPoint(x: 50, y: 50)
    @State private var dragStart: CGPoint?
    @State private var videoSize = CGSize(width: 9, height: 16)
    
    let myClass: MyClass
    private let orangeSize: CGFloat = 150

    /// Camera buffers are often landscape; swap so the preview matches the container.
    private func videoFrameSize(in containerSize: CGSize) -> CGSize {
        var displaySize = videoSize
        print("VIDEO SIZE:", videoSize)
        let bufferIsLandscape = videoSize.width > videoSize.height
        let containerIsPortrait = containerSize.height >= containerSize.width
        if containerIsPortrait && bufferIsLandscape {
            displaySize = CGSize(width: videoSize.height, height: videoSize.width)
        }
        guard displaySize.height > 0 else {
            return CGSize(width: orangeSize * 9 / 16, height: orangeSize)
        }
        return CGSize(width: orangeSize * displaySize.width / displaySize.height, height: orangeSize)
    }

    init(myClass: MyClass) {
        self.myClass = myClass
        
//        if appUser.id == myClass.studentId {
//            _userId = State(initialValue: String(myClass.studentId))
//            _targetUserId = State(initialValue: String(myClass.instructorId))
//        }
//        
//        if (appUser.id == myClass.instructorId) {
//            _userId = State(initialValue: String(myClass.instructorId))
//            _targetUserId = State(initialValue: String(myClass.studentId))
//        }
        
    }

    var body: some View {
        
        if !isConnected {
            VStack {
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 30, height: 30)
                    
                    Text(appUser.name!)
                }
                Button("Connect") {
                        webRTCManager.connect(userId: String(appUser.id!))
                        isConnected = true
                }
            }
            
        } else {
            ZStack {
                ReaderView()

                if let localTrack = webRTCManager.localVideoTrack {
                    GeometryReader { geo in
                        let frameSize = videoFrameSize(in: geo.size)
                        VideoView(videoTrack: localTrack, videoSize: $videoSize)
                            .frame(width: frameSize.width, height: frameSize.height)
                            .clipped()
                            .position(orangePosition)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if dragStart == nil {
                                            dragStart = orangePosition
                                        }
                                        let start = dragStart ?? orangePosition
                                        orangePosition = clampedPosition(
                                            CGPoint(
                                                x: start.x + value.translation.width,
                                                y: start.y + value.translation.height
                                            ),
                                            in: geo.size,
                                            frameSize: frameSize
                                        )
                                    }
                                    .onEnded { _ in
                                        dragStart = nil
                                    }
                            )
                    }
                }
               
            }
        }
        
//        .ignoresSafeArea(.all)
    }

    private func clampedPosition(_ location: CGPoint, in size: CGSize, frameSize: CGSize) -> CGPoint {
        let halfWidth = frameSize.width / 2
        let halfHeight = frameSize.height / 2
        return CGPoint(
            x: min(max(location.x, halfWidth), size.width - halfWidth),
            y: min(max(location.y, halfHeight), size.height - halfHeight)
        )
    }
}

#Preview {
    ZView(myClass: MyClass(
        studentId: User.studentPreview.id!, instructorId: User.instructorPreview.id!
    ))
    .environment(User.preview)
}
