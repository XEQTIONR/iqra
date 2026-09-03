//
//  ZView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-17.
//

import SwiftUI

struct ZView: View {
    
    private var appUser: User
    @StateObject private var webRTCManager: WebRTCManager
    
    @State private var userId: String
    @State private var targetUserId: String
    @State private var isConnected: Bool
    @State private var isLive: Bool = false
    
    @State private var orangePosition = CGPoint(x: 50, y: 50)
    @State private var dragStart: CGPoint?
    @State private var videoSize = CGSize(width: 9, height: 16)
    
    let myClass: MyClass
    private let orangeSize: CGFloat = 300

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

    init(myClass: MyClass, user: User) {
        
        self.myClass = myClass
        self.appUser = user
        
        if appUser.id == myClass.studentId {
            _userId = State(initialValue: String(myClass.studentId))
            _targetUserId = State(initialValue: String(myClass.instructorId))
        } else { // (appUser.id == myClass.instructorId)
            _userId = State(initialValue: String(myClass.instructorId))
            _targetUserId = State(initialValue: String(myClass.studentId))
        }
        
        let webRTCManager = WebRTCManager()
        webRTCManager.onGuestJoin = { [weak webRTCManager] idStr in
            webRTCManager?.startCall(to: idStr)
        }
        _webRTCManager = StateObject(wrappedValue: webRTCManager)
        _isConnected = State(initialValue: true)
    }

    var body: some View {
        if !isLive {
            
            GeometryReader { geo in
                VStack {
                    let frameSize = videoFrameSize(in: geo.size)
                    if let localTrack = webRTCManager.localVideoTrack {
                        VideoView(videoTrack: localTrack, videoSize: $videoSize)
                            .frame(width: frameSize.width, height: frameSize.height)
                            .clipped()
                    }

                    Button("Connect") {
                        // Step #1
                        webRTCManager.connect(userId: String(userId), classId: myClass.id)
                        isLive = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            ZStack {
//                ReaderView()

                if let localTrack = webRTCManager.localVideoTrack {
                    GeometryReader { geo in
                        let frameSize = videoFrameSize(in: geo.size)
                        
                        if let remoteTrack = webRTCManager.remoteVideoTrack {

                            VideoView(videoTrack: remoteTrack, videoSize: $videoSize)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                            
                            
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
                        } else {
                            VideoView(videoTrack: localTrack, videoSize: $videoSize)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
    //                            .position(orangePosition)
    //                            .gesture(
    //                                DragGesture()
    //                                    .onChanged { value in
    //                                        if dragStart == nil {
    //                                            dragStart = orangePosition
    //                                        }
    //                                        let start = dragStart ?? orangePosition
    //                                        orangePosition = clampedPosition(
    //                                            CGPoint(
    //                                                x: start.x + value.translation.width,
    //                                                y: start.y + value.translation.height
    //                                            ),
    //                                            in: geo.size,
    //                                            frameSize: frameSize
    //                                        )
    //                                    }
    //                                    .onEnded { _ in
    //                                        dragStart = nil
    //                                    }
    //                            )
                        }
                        
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
    ZView(
        myClass: MyClass(
            studentId: User.studentPreview.id!,
            instructorId: User.instructorPreview.id!,
            courseFormatId: CourseFormat.preview.id!
        ),
        user: User.studentPreview
    )

}
