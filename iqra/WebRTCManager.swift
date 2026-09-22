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
    enum MediaCaptureMode {
        case video
        case audioOnly
    }

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
    private var isShutdown = false
    
    // State
    @Published var isConnected = false
    @Published var isCallActive = false
    @Published var isCameraEnabled = true
    @Published var isMicrophoneEnabled = true
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?
    
    
    public var onGuestJoin: ((String) -> Void)?
    public var onGuestLeave: ((String) -> Void)?
    public var onPartnerDrewPath: ((UserPath) -> Void)?
    
    
    
    // Configuration
    private let stunServers = [
        "stun:stun.l.google.com:19302",
        "stun:stun1.l.google.com:19302"
    ]
    
    init(
        captureMode: MediaCaptureMode = .video,
        onGuestJoin: ((String) -> Void)? = nil,
        onGuestLeave: ((String) -> Void)? = nil,
        onPartnerDrewPath: ((UserPath) -> Void)? = nil,
    ) {
        super.init()
        
        self.isCameraEnabled = captureMode == .video
        self.isMicrophoneEnabled = true
        self.onGuestJoin = onGuestJoin
        self.onGuestLeave = onGuestLeave
        self.onPartnerDrewPath = onPartnerDrewPath
        
        print("📱 WebRTCManager init started")

        guard !ProcessInfo.isRunningInPreview else {
            print("📱 WebRTCManager skipped media setup (preview)")
            return
        }
        
        setupLocalMedia()

        signalingClient = SignalingClient(webRTCManager: self)
        
        print("📱 WebRTCManager init completed")
    }

    deinit {
        iceDisconnectWorkItem?.cancel()
        iceDisconnectWorkItem = nil
        videoCapturer?.stopCapture()
        videoCapturer = nil
        signalingClient?.disconnect()
    }
    
    public func sendPath(path: UserPath) {
        
        guard isCallActive,
              let signalingClient,
              let partner = signalingClient.currentCallPartner
        else { return }
        
        signalingClient.sendPath(to: partner, path: path)
    }
    
    func connect(userId: String, classId: String) {
        print("🔌 Connecting to signaling server as: \(userId) for class: \(classId)")
        signalingClient?.connect(userId: userId, classId: classId)
    }
    
    private func setupLocalMedia() {
        print("📍 setupLocalMedia called")
        
        configureAudioSession()
        setupAudioTrack()
        setupVideoTrack()
        
        if isMicrophoneEnabled {
            checkMicrophonePermissionAndEnable()
        }
        
        if isCameraEnabled {
            checkCameraPermissionAndStartCapture()
        } else {
            videoTrack?.isEnabled = false
            localVideoTrack = nil
            print("🎙️ Audio-only capture; camera not started")
        }
    }

    func setCaptureMode(_ mode: MediaCaptureMode) {
        setCameraEnabled(mode == .video)
    }

    func setCameraEnabled(_ enabled: Bool) {
        let apply = { [weak self] in
            guard let self else { return }
            self.isCameraEnabled = enabled
            if enabled {
                self.configureAudioSession()
                self.checkCameraPermissionAndStartCapture()
            } else {
                self.stopVideoCapture()
                self.configureAudioSession()
            }
        }
        if Thread.isMainThread {
            apply()
        } else {
            DispatchQueue.main.async(execute: apply)
        }
    }

    func setMicrophoneEnabled(_ enabled: Bool) {
        let apply = { [weak self] in
            guard let self else { return }
            self.isMicrophoneEnabled = enabled
            if enabled {
                self.checkMicrophonePermissionAndEnable()
            } else {
                self.audioTrack?.isEnabled = false
                print("🔇 Microphone disabled")
            }
        }
        if Thread.isMainThread {
            apply()
        } else {
            DispatchQueue.main.async(execute: apply)
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: isCameraEnabled ? .videoChat : .voiceChat,
                options: [.allowBluetooth, .defaultToSpeaker]
            )
            try session.setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func setupAudioTrack() {
        let audioSource = factory.audioSource(with: nil)
        let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        audioTrack.isEnabled = isMicrophoneEnabled
        self.audioTrack = audioTrack
        print("✅ Audio track created")
    }

    private func setupVideoTrack() {
        videoSource = factory.videoSource()
        let videoTrack = factory.videoTrack(with: videoSource!, trackId: "video0")
        videoTrack.isEnabled = isCameraEnabled
        self.videoTrack = videoTrack
        print("✅ Video track created")
    }

    private func checkMicrophonePermissionAndEnable() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            print("🎙️ Microphone already authorized")
            audioTrack?.isEnabled = true
            isMicrophoneEnabled = true

        case .notDetermined:
            print("🎙️ Requesting microphone permission")
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.audioTrack?.isEnabled = true
                        self.isMicrophoneEnabled = true
                        print("✅ Microphone permission granted")
                    } else {
                        self.audioTrack?.isEnabled = false
                        self.isMicrophoneEnabled = false
                        print("❌ Microphone permission denied")
                    }
                }
            }

        case .denied, .restricted:
            audioTrack?.isEnabled = false
            isMicrophoneEnabled = false
            print("❌ Microphone permission denied or restricted")

        @unknown default:
            print("❌ Unknown microphone permission status")
        }
    }
    
    private func checkCameraPermissionAndStartCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("📷 Camera already authorized")
            startVideoCapture()
            
        case .notDetermined:
            print("📷 Requesting camera permission")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.startVideoCapture()
                    } else {
                        self.isCameraEnabled = false
                        self.videoTrack?.isEnabled = false
                        self.localVideoTrack = nil
                        print("❌ Camera permission denied")
                    }
                }
            }
            
        case .denied, .restricted:
            isCameraEnabled = false
            videoTrack?.isEnabled = false
            localVideoTrack = nil
            print("❌ Camera permission denied or restricted")
            
        @unknown default:
            print("❌ Unknown camera permission status")
        }
    }

    private func stopVideoCapture() {
        videoTrack?.isEnabled = false
        localVideoTrack = nil

        guard let capturer = videoCapturer else {
            print("🛑 Camera already stopped")
            return
        }

        capturer.stopCapture { [weak self] in
            DispatchQueue.main.async {
                self?.videoCapturer = nil
                print("🛑 Camera capture stopped")
            }
        }
    }
    
    private func startVideoCapture() {
        print("🎥 startVideoCapture called")

        if videoCapturer != nil {
            videoTrack?.isEnabled = true
            localVideoTrack = videoTrack
            isCameraEnabled = true
            print("🎥 Video capture already running")
            return
        }
        
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
        
        guard let camera = devices.first(where: { $0.position == .front }) else {
            videoCapturer = nil
            isCameraEnabled = false
            videoTrack?.isEnabled = false
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
            videoCapturer = nil
            isCameraEnabled = false
            videoTrack?.isEnabled = false
            print("❌ No formats available")
            return
        }

        let size = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
        let fps = selectCaptureFps(for: format)
        print("📐 Selected format: \(size.width)x\(size.height) at \(fps) fps")

        capturer.startCapture(with: camera, format: format, fps: fps) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error = error {
                    self.videoCapturer = nil
                    self.videoTrack?.isEnabled = false
                    self.localVideoTrack = nil
                    self.isCameraEnabled = false
                    print("❌ Failed to start capture: \(error.localizedDescription)")
                    return
                }

                self.videoTrack?.isEnabled = true
                self.localVideoTrack = self.videoTrack
                self.isCameraEnabled = true
                print("✅ Camera capture started successfully!")
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
        teardownPeerConnection()
        
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
        
        if let videoTrack = videoTrack {
            videoTrack.isEnabled = isCameraEnabled
            peerConnection?.add(videoTrack, streamIds: ["stream0"])
            print("✅ Video track added to peer connection (enabled: \(isCameraEnabled))")
        }
        
        if let audioTrack = audioTrack {
            audioTrack.isEnabled = isMicrophoneEnabled
            peerConnection?.add(audioTrack, streamIds: ["stream0"])
            print("✅ Audio track added to peer connection (enabled: \(isMicrophoneEnabled))")
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
        guard !isShutdown else { return }
        print("📞 Hanging up")
        closePeerConnection()
        signalingClient?.currentCallPartner = nil
    }

    func shutdown() {
        guard !isShutdown else { return }
        isShutdown = true
        print("🔌 Shutting down WebRTC session")

        cancelIceDisconnectHangUp()
        signalingClient?.disconnect()
        signalingClient = nil

        teardownPeerConnection()

        videoTrack?.isEnabled = false
        audioTrack?.isEnabled = false
        localVideoTrack = nil
        remoteVideoTrack = nil
        isCameraEnabled = false
        isMicrophoneEnabled = false
        isConnected = false
        isCallActive = false

        if let capturer = videoCapturer {
            capturer.stopCapture()
            videoCapturer = nil
            print("🛑 Camera capture stopped")
        }

        deactivateAudioSession()
    }

    private func deactivateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
            print("✅ Audio session deactivated")
        } catch {
            print("❌ Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    private func closePeerConnection() {
        teardownPeerConnection()
        remoteVideoTrack = nil
        isCallActive = false
    }

    /// Nil `peerConnection` before `close()` so teardown callbacks cannot pass `isCurrent`
    /// and later overwrite a newly received remote track.
    private func teardownPeerConnection() {
        cancelIceDisconnectHangUp()
        let connection = peerConnection
        peerConnection = nil
        connection?.close()
    }
    
    private func isCurrent(_ peerConnection: RTCPeerConnection) -> Bool {
        peerConnection === self.peerConnection
    }

    private func applyRemoteVideoTrack(_ track: RTCVideoTrack?, from peerConnection: RTCPeerConnection) {
        let apply = { [weak self] in
            guard let self, !self.isShutdown, self.isCurrent(peerConnection) else { return }
            if let track {
                track.isEnabled = true
                print("✅ Remote video track received")
            }
            self.remoteVideoTrack = track
        }
        if Thread.isMainThread {
            apply()
        } else {
            DispatchQueue.main.async(execute: apply)
        }
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
        print("=== Media State Debug ===")
        print("audioTrack: \(audioTrack != nil)")
        print("isMicrophoneEnabled: \(isMicrophoneEnabled)")
        print("videoSource: \(videoSource != nil)")
        print("videoTrack: \(videoTrack != nil)")
        print("videoCapturer: \(videoCapturer != nil)")
        print("isCameraEnabled: \(isCameraEnabled)")
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
        print("Stream added with \(stream.videoTracks.count) video tracks")
        guard let videoTrack = stream.videoTracks.first else { return }
        applyRemoteVideoTrack(videoTrack, from: peerConnection)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        // Unified Plan still emits stream removal while the RTP receiver remains.
        // Clearing here hides remote video as soon as the peer connects.
        print("Stream removed")
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd rtpReceiver: RTCRtpReceiver,
        streams mediaStreams: [RTCMediaStream]
    ) {
        guard let videoTrack = rtpReceiver.track as? RTCVideoTrack else { return }
        applyRemoteVideoTrack(videoTrack, from: peerConnection)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove rtpReceiver: RTCRtpReceiver) {
        guard let videoTrack = rtpReceiver.track as? RTCVideoTrack else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.isShutdown, self.isCurrent(peerConnection) else { return }
            guard self.remoteVideoTrack === videoTrack else { return }
            self.remoteVideoTrack = nil
        }
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE connection state: \(newState.rawValue)")
        guard !isShutdown, isCurrent(peerConnection) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.isShutdown, self.isCurrent(peerConnection) else { return }
            
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
