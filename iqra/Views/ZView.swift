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
    
    @State var myClass: MyClass
    private let orangeSize: CGFloat = 200

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
                }
            }
            
        } else {
            ZStack {
                ReaderView()

                if let localTrack = webRTCManager.localVideoTrack {
                    GeometryReader { geo in
                        VideoView(videoTrack: localTrack)
//                            .fill(Color.orange)
                            .frame(height: orangeSize)
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
                                            in: geo.size
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

    private func clampedPosition(_ location: CGPoint, in size: CGSize) -> CGPoint {
        let half = orangeSize / 2
        return CGPoint(
            x: min(max(location.x, half), size.width - half),
            y: min(max(location.y, half), size.height - half)
        )
    }
}

#Preview {
    ZView(myClass: MyClass(
        studentId: User.studentPreview.id!, instructorId: User.instructorPreview.id!
    ))
    .environment(User.preview)
}
