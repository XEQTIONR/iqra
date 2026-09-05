//
//  WebRTCManager.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-09.
//

import Foundation
import WebRTC
import AVFoundation
import UIKit

class WebRTCManager: NSObject, ObservableObject {
    // WebRTC components
    private var peerConnection: RTCPeerConnection?
    private var videoSource: RTCVideoSource?
    private var videoTrack: RTCVideoTrack?
    private var audioTrack: RTCAudioTrack?
    private lazy var factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
    }()
    private var videoCapturer: RTCCameraVideoCapturer?
    
    // Signaling client
    private var signalingClient: SignalingClient?
    private var iceDisconnectWorkItem: DispatchWorkItem?
    private let iceDisconnectGracePeriod: TimeInterval = 5
    
    // State
    @Published var isConnected = false
    @Published var isCallActive = false
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?
    
    public var onDraw: ((UserPath) -> Void)?
    public var onGuestJoin: ((String) -> Void)?
    public var onGuestLeave: ((String) -> Void)?
    
    // Configuration
    private let stunServers = [
        "stun:stun.l.google.com:19302",
        "stun:stun1.l.google.com:19302"
    ]
    
    init(
        onDraw: ((UserPath) -> Void)? = nil,
        onGuestJoin: ((String) -> Void)? = nil,
        onGuestLeave: ((String) -> Void)? = nil,
    ) {
        super.init()
        
        self.onDraw = onDraw
        self.onGuestJoin = onGuestJoin
        self.onGuestLeave = onGuestLeave
        
        print("📱 WebRTCManager init started")

        guard !ProcessInfo.isRunningInPreview else {
            print("📱 WebRTCManager skipped media setup (preview)")
            return
        }
        
        setupLocalMedia()

        signalingClient = SignalingClient(webRTCManager: self)
        
        print("📱 WebRTCManager init completed")
    }
    
    func connect(userId: String, classId: String) {
        print("🔌 Connecting to signaling server as: \(userId) for class: \(classId)")
        signalingClient?.connect(userId: userId, classId: classId)
    }
    
    private func setupLocalMedia() {
        print("📍 setupLocalMedia called")
        
        // Create audio track
        let audioSource = factory.audioSource(with: nil)
        let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        self.audioTrack = audioTrack
        print("✅ Audio track created")
        
        // Create video source and track
        videoSource = factory.videoSource()
        let videoTrack = factory.videoTrack(with: videoSource!, trackId: "video0")
        self.videoTrack = videoTrack
        self.localVideoTrack = videoTrack
        print("✅ Video track created and published")
        
        // Request and start camera capture
        checkCameraPermissionAndStartCapture()
    }
    
    private func checkCameraPermissionAndStartCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("📷 Camera already authorized")
            startVideoCapture()
            
        case .notDetermined:
            print("📷 Requesting camera permission")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.startVideoCapture()
                    }
                } else {
                    print("❌ Camera permission denied")
                }
            }
            
        case .denied, .restricted:
            print("❌ Camera permission denied or restricted")
            
        @unknown default:
            print("❌ Unknown camera permission status")
        }
    }
    
    private func startVideoCapture() {
        print("🎥 startVideoCapture called")
        
        guard let videoSource = videoSource else {
            print("❌ videoSource is nil")
            return
        }
        
        // Create and retain the capturer
        let capturer = RTCCameraVideoCapturer(delegate: videoSource)
        self.videoCapturer = capturer
        print("✅ Video capturer created")
        
        // Get available cameras
        let devices = RTCCameraVideoCapturer.captureDevices()
        print("📱 Available cameras: \(devices.map { $0.localizedName })")
        
        // Get front camera
        guard let camera = devices.first(where: { $0.position == .front }) else {
            print("❌ No front camera found")
            return
        }
        print("📱 Using camera: \(camera.localizedName)")
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: camera)
        print("📐 Available formats: \(formats.count)")

        guard let format = selectCaptureFormat(
            from: formats,
            preferredPixelFormat: capturer.preferredOutputPixelFormat()
        ) else {
            print("❌ No formats available")
            return
        }

        let size = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        let fps = selectCaptureFps(for: format)
        print("📐 Selected format: \(size.width)x\(size.height) at \(fps) fps")

        capturer.startCapture(with: camera, format: format, fps: fps) { [weak self] error in
            if let error = error {
                print("❌ Failed to start capture: \(error.localizedDescription)")
            } else {
                print("✅ Camera capture started successfully!")
                
                // Force a UI update on main thread
                DispatchQueue.main.async {
                    // Ensure video track is still published
                    if self?.localVideoTrack == nil {
                        self?.localVideoTrack = self?.videoTrack
                    }
                }
            }
        }
    }

    private func selectCaptureFormat(
        from formats: [AVCaptureDevice.Format],
        preferredPixelFormat: FourCharCode
    ) -> AVCaptureDevice.Format? {
        let targetWidth: Int32 = 1280
        let targetHeight: Int32 = 720
        var selectedFormat: AVCaptureDevice.Format?
        var closestDiff = Int32.max

        for format in formats {
            let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height)
            let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription)

            if diff < closestDiff {
                selectedFormat = format
                closestDiff = diff
            } else if diff == closestDiff && pixelFormat == preferredPixelFormat {
                selectedFormat = format
            }
        }

        return selectedFormat
    }

    private func selectCaptureFps(for format: AVCaptureDevice.Format, target: Float64 = 30) -> Int {
        let maxSupported = format.videoSupportedFrameRateRanges.map(\.maxFrameRate).max() ?? target
        return Int(min(maxSupported, target))
    }
    
    func startCall(to userId: String) {
        print("📞 Starting call to: \(userId)")
        // Step #2
        createPeerConnection()
        
        
        createOffer { [weak self] sdp in
            self?.signalingClient?.sendCall(to: userId, sdp: sdp)
        }
    }
    
    // Step #5
    func acceptCall(from userId: String, withOffer sdp: String) {
        print("📞 Accepting call from: \(userId)")
        createPeerConnection()
        setRemoteDescription(sdp: sdp, type: .offer) { [weak self] in
            // Step #6
            self?.createAnswer { answerSdp in
                self?.signalingClient?.sendAnswer(to: userId, sdp: answerSdp)
            }
        }
    }
    
    private func createPeerConnection() {
        print("🔌 Creating peer connection")
        closePeerConnection()
        
        let config = RTCConfiguration()
        config.iceServers = stunServers.map { RTCIceServer(urlStrings: [$0]) }
        config.iceTransportPolicy = .all
        config.bundlePolicy = .maxBundle
        config.rtcpMuxPolicy = .require
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        
        peerConnection = factory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
        
        // Add tracks
        if let videoTrack = videoTrack {
            peerConnection?.add(videoTrack, streamIds: ["stream0"])
            videoTrack.isEnabled = true
            print("✅ Video track added to peer connection")
        }
        
        if let audioTrack = audioTrack {
            peerConnection?.add(audioTrack, streamIds: ["stream0"])
            print("✅ Audio track added to peer connection")
        }
    }
    
    private func createOffer(completion: @escaping (String) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "true"
            ],
            optionalConstraints: nil
        )
        
        peerConnection?.offer(for: constraints) { [weak self] sdp, error in
            if let error = error {
                print("❌ Failed to create offer: \(error)")
                return
            }
            
            guard let self, let sdp else { return }
            guard let peerConnection = self.peerConnection else { return }
            peerConnection.setLocalDescription(sdp) { error in
                if let error = error {
                    print("❌ Failed to set local description: \(error)")
                }
            }
            completion(sdp.sdp)
        }
    }
    
    private func createAnswer(completion: @escaping (String) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "true"
            ],
            optionalConstraints: nil
        )
        
        peerConnection?.answer(for: constraints) { [weak self] sdp, error in
            if let error = error {
                print("❌ Failed to create answer: \(error)")
                return
            }
            
            guard let self, let sdp else { return }
            guard let peerConnection = self.peerConnection else { return }
            peerConnection.setLocalDescription(sdp) { error in
                if let error = error {
                    print("❌ Failed to set local description: \(error)")
                }
            }
            completion(sdp.sdp)
        }
    }
    
    func setRemoteDescription(sdp: String, type: RTCSdpType, completion: @escaping () -> Void) {
        guard peerConnection != nil else {
            print("⚠️ Ignoring remote description; no active peer connection")
            return
        }
        let sessionDescription = RTCSessionDescription(type: type, sdp: sdp)
        peerConnection?.setRemoteDescription(sessionDescription) { [weak self] error in
            if let error = error {
                print("❌ Failed to set remote description: \(error)")
                return
            }
            guard self?.peerConnection != nil else { return }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func handleICECandidate(_ candidate: String, sdpMid: String, sdpMLineIndex: Int32) {
        guard peerConnection != nil else {
            print("⚠️ Ignoring ICE candidate; no active peer connection")
            return
        }
        
        let candidateObj = RTCIceCandidate(
            sdp: candidate,
            sdpMLineIndex: sdpMLineIndex,
            sdpMid: sdpMid
        )
        peerConnection?.add(candidateObj) { error in
            if let error = error {
                print("❌ Failed to add ICE candidate: \(error.localizedDescription)")
            } else {
                print("✅ ICE candidate added successfully")
            }
        }
    }
    
    func hangUp() {
        print("📞 Hanging up")
        closePeerConnection()
        signalingClient?.currentCallPartner = nil
    }
    
    private func closePeerConnection() {
        cancelIceDisconnectHangUp()
        peerConnection?.close()
        peerConnection = nil
        
        let applyIdleState = { [weak self] in
            guard let self, self.peerConnection == nil else { return }
            self.remoteVideoTrack = nil
            self.isCallActive = false
        }
        if Thread.isMainThread {
            applyIdleState()
        } else {
            DispatchQueue.main.async(execute: applyIdleState)
        }
    }
    
    private func isCurrent(_ peerConnection: RTCPeerConnection) -> Bool {
        peerConnection === self.peerConnection
    }
    
    private func scheduleHangUpAfterIceDisconnect() {
        cancelIceDisconnectHangUp()
        let workItem = DispatchWorkItem { [weak self] in
            print("⏱️ ICE disconnect grace expired; hanging up")
            self?.hangUp()
        }
        iceDisconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + iceDisconnectGracePeriod, execute: workItem)
    }
    
    private func cancelIceDisconnectHangUp() {
        iceDisconnectWorkItem?.cancel()
        iceDisconnectWorkItem = nil
    }
    
    func checkVideoState() {
        print("=== Video State Debug ===")
        print("videoSource: \(videoSource != nil)")
        print("videoTrack: \(videoTrack != nil)")
        print("videoCapturer: \(videoCapturer != nil)")
        print("localVideoTrack published: \(localVideoTrack != nil)")
        print("=========================")
    }
}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling state: \(stateChanged.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        guard isCurrent(peerConnection) else { return }
        print("Stream added with \(stream.videoTracks.count) video tracks")
        if let videoTrack = stream.videoTracks.first {
            DispatchQueue.main.async { [weak self] in
                guard let self, self.isCurrent(peerConnection) else { return }
                self.remoteVideoTrack = videoTrack
                print("✅ Remote video track received")
            }
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        guard isCurrent(peerConnection) else { return }
        print("Stream removed")
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isCurrent(peerConnection) else { return }
            self.remoteVideoTrack = nil
        }
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE connection state: \(newState.rawValue)")
        guard isCurrent(peerConnection) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isCurrent(peerConnection) else { return }
            
            switch newState {
            case .connected, .completed:
                self.cancelIceDisconnectHangUp()
                self.isCallActive = true
            case .disconnected:
                self.isCallActive = false
                self.scheduleHangUpAfterIceDisconnect()
            case .failed:
                print("❌ ICE failed; hanging up")
                self.hangUp()
            case .closed:
                self.isCallActive = false
            default:
                break
            }
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE gathering state: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        guard isCurrent(peerConnection) else { return }
        guard let partner = signalingClient?.currentCallPartner, !partner.isEmpty else {
            print("⚠️ Skipping ICE candidate; no call partner")
            return
        }
        print("Generated ICE candidate")
        signalingClient?.sendICECandidate(
            to: partner,
            candidate: candidate.sdp,
            sdpMid: candidate.sdpMid ?? "",
            sdpMLineIndex: candidate.sdpMLineIndex
        )
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("Removed \(candidates.count) ICE candidates")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Data channel opened: \(dataChannel.label)")
    }
}
