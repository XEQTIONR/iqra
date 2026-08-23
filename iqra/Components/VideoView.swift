//
//  VideoView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-23.
//

import SwiftUI
import WebRTC

// Video rendering view
struct VideoView: UIViewRepresentable {
    let videoTrack: RTCVideoTrack
    var videoSize: Binding<CGSize>? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(videoSize: videoSize)
    }

    func makeUIView(context: Context) -> RTCMTLVideoView {
        let videoView = RTCMTLVideoView(frame: .zero)
        videoView.videoContentMode = .scaleAspectFill
        videoView.clipsToBounds = true
        videoView.delegate = context.coordinator
        return videoView
    }

    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        context.coordinator.videoSize = videoSize
        uiView.delegate = context.coordinator
        videoTrack.add(uiView)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: RTCMTLVideoView, context: Context) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    final class Coordinator: NSObject, RTCVideoViewDelegate {
        var videoSize: Binding<CGSize>?

        init(videoSize: Binding<CGSize>?) {
            self.videoSize = videoSize
        }

        func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
            DispatchQueue.main.async {
                self.videoSize?.wrappedValue = size
            }
        }
    }
}

//#Preview {
//    VideoView()
//}
