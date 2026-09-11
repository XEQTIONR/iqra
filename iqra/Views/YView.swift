//
//  YView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-09-01.
//

import SwiftUI
import WebRTC

struct YView: View {

    private enum MenuAnchor {
        case top
        case bottom
    }
    
    @Environment(ClassSession.self) private var classSession
    
    private let appUser: User
    private let myClass: MyClass
    private let remoteVideoScaleFactor: CGFloat = 300
    
    @State private var userId: String
    @State private var targetUserId: String
    @State private var isConnected: Bool
    @State private var isLive: Bool = false
    @State private var remoteVideoPosition = CGPoint(x: 50, y: 50)
    @State private var dragStart: CGPoint?
    @State private var videoSize = CGSize(width: 9, height: 16)
    
    @State private var webRTCManager: WebRTCManager?

    @State private var menuAnchor: MenuAnchor?
    @State private var canDraw = false
    @State private var collapseProgress: CGFloat = 1 //minmax 0 or 1
    @State private var collapseDrag: CGFloat = 1 //minmax 0 or 1
    @State private var splitRestLength: CGFloat = 300
    
    @State private var isLocalPreviewOn = false
    
    
    /// Camera buffers are often landscape; swap so the preview matches the container.
    private func videoFrameSize(in containerSize: CGSize) -> CGFloat {
        
        enum Dim {
            case width
            case height
        }
        
        let displaySize = containerSize
        let shortDim = displaySize.width < displaySize.height ? Dim.width : Dim.height
        let sideLength = shortDim == Dim.width ? displaySize.width : displaySize.height
        // print("VIDEO SIZE:", videoSize)
//        let bufferIsLandscape = videoSize.width > videoSize.height
//        let containerIsPortrait = containerSize.height >= containerSize.width
//        if containerIsPortrait && bufferIsLandscape {
//            displaySize = CGSize(width: videoSize.height, height: videoSize.width)
//        }
//        guard displaySize.height > 0 else {
//            return CGSize(width: remoteVideoScaleFactor * 9 / 16, height: remoteVideoScaleFactor)
//        }
        return sideLength
    }

    private var displayedCollapse: CGFloat {
        min(max(collapseProgress + collapseDrag, 0), 1)
    }

    var r1: some View {
        GeometryReader { geo in
            let minDim = min(geo.size.width, geo.size.height)
            
            VStack() {
                
                Spacer()
                
                if let webRTCManager, isLocalPreviewOn {
                    LocalCameraPreview(
                        webRTCManager: webRTCManager,
                        videoSize: $videoSize,
                        minDim: minDim
                    )
                } else {
                    Rectangle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: minDim, height: minDim)
                }
                
                Spacer()
                    
                VStack(spacing: 10) {
                    HStack {
                        Button("Join with audio", systemImage: "mic.fill") {
                            startWebRTCIfNeeded(captureMode: .audioOnly)
                            webRTCManager?.setCaptureMode(.audioOnly)
                            isLocalPreviewOn = false
                        }
                        .filledBackground()
                        
                        Button("Join with video", systemImage: isLocalPreviewOn ? "video.slash.fill" : "video.fill") {
                            startWebRTCIfNeeded(captureMode: .video)
                            if isLocalPreviewOn {
                                isLocalPreviewOn = false
                            } else {
                                webRTCManager?.setCaptureMode(.video)
                                isLocalPreviewOn = true
                            }
                        }
                        .filledBackground()
                    }
                    
                    Button("Join") {
                        //startWebRTCIfNeeded(captureMode: .video)
                    }
                    .filledBackground()
                    .disabled(webRTCManager == nil)
                }
                .padding(.horizontal)
                .padding(.bottom, 75)
                    
            }
//            .padding(.top, 200)
//            .padding(.bottom, 75)
                .ignoresSafeArea(edges: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .background(.pink)
        }
        
            
            
    }

    var r2: some View {
        VStack {
            Text("Hello2")
                .foregroundStyle(.white)
        }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue)
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

        _isConnected = State(initialValue: true)

    }

    private func startWebRTCIfNeeded(captureMode: WebRTCManager.MediaCaptureMode) {
        guard webRTCManager == nil else { return }
        let manager = WebRTCManager(captureMode: captureMode)
        manager.onGuestJoin = { [weak manager] idStr in
            manager?.startCall(to: idStr)
        }
        manager.onGuestLeave = { [weak manager] _ in
            manager?.hangUp()
        }
        webRTCManager = manager
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geo in
                    let isLandscape = geo.size.width > geo.size.height
                    let progress = displayedCollapse
                    let spacing = 10 * (1 - progress)
                    let restLength = isLandscape
                        ? (geo.size.width - 10) / 2
                        : (geo.size.height - 10) / 2
                    let r1Size = isLandscape
                        ? CGSize(
                            width: restLength + progress * (geo.size.width - restLength),
                            height: geo.size.height
                        )
                        : CGSize(
                            width: geo.size.width,
                            height: restLength + progress * (geo.size.height - restLength)
                        )
                    let r2Size = isLandscape
                        ? CGSize(width: restLength, height: geo.size.height)
                        : CGSize(width: geo.size.width, height: restLength)
                    let r2Offset = isLandscape
                        ? CGSize(width: r1Size.width + spacing, height: progress * geo.size.height)
                        : CGSize(width: 0, height: r1Size.height + spacing)
                    let cornerRadius = 25 * (1 - progress)

                    ZStack(alignment: .topLeading) {
                        r1
                            .frame(width: r1Size.width, height: r1Size.height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .gesture(progress > 0.02 ? collapseDragGesture(restLength: restLength) : nil)

                        r2
                            .frame(width: r2Size.width, height: r2Size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .offset(x: r2Offset.width, y: r2Offset.height)
                            .contentShape(Rectangle())
                            .highPriorityGesture(progress < 0.98 ? collapseDragGesture(restLength: restLength) : nil)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                    .clipped()
                    .background(.black)
                    .onAppear { splitRestLength = restLength }
                    .onChange(of: restLength) { _, newValue in
                        splitRestLength = newValue
                    }
                }
                .ignoresSafeArea()

                if let menuAnchor {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissMenu()
                        }

                    dropdownMenu
                        .padding(.trailing, 12)
                        .padding(.top, menuAnchor == .top ? 20 : 0)
                        .padding(.bottom, menuAnchor == .bottom ? 63 : 0)
                        .safeAreaPadding(menuAnchor == .bottom ? .bottom : [])
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: menuAnchor == .top ? .topTrailing : .bottomTrailing
                        )
                        .transition(
                            .scale(
                                scale: 0.5,
                                anchor: menuAnchor == .top ? .topTrailing : .bottomTrailing
                            )
                            .combined(with: .opacity)
                        )
                }
// Bottom Bar
                VStack(spacing: 0) {
                    Spacer()
                        .allowsHitTesting(false)
//                    bottomButtonBar
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 20)
//                        .contentShape(Rectangle())
//                        .simultaneousGesture(collapseDragGesture(restLength: splitRestLength))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    HStack(spacing: 8) {
                        backButton
                    }
                    .padding(.top, 20)
                }
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        menuButton(anchor: .top)
                    }
                    .padding(.top, 20)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var bottomButtonBar: some View {
        HStack(spacing: 8) {
            Spacer()
            if let webRTCManager {
                CallMediaControls(webRTCManager: webRTCManager)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

//    private var cameraToggleButton: some View {
//        toolbarCircleButton(
//            title: isCameraOn ? "Turn Camera Off" : "Turn Camera On",
//            systemImage: isCameraOn ? "video.fill" : "video.slash.fill",
//            foreground: isCameraOn ? .accentColor : .secondary,
//            size: 60
//        ) {
//            isCameraOn.toggle()
//        }
//        .accessibilityAddTraits(isCameraOn ? [.isSelected] : [])
//        .accessibilityHint("Toggles the camera")
//    }

    private var drawToggleButton: some View {
        toolbarCircleButton(
            title: canDraw ? "Disable Drawing" : "Enable Drawing",
            systemImage: canDraw ? "pencil" : "pencil.slash",
            foreground: canDraw ? .accentColor : .secondary
        ) {
            canDraw.toggle()
        }
        .accessibilityAddTraits(canDraw ? [.isSelected] : [])
        .accessibilityHint("Toggles drawing")
    }
    
    private var backButton: some View {
        toolbarCircleButton(
            title: "Back",
            systemImage: "chevron.left"
        ) {
            print("back Clicked")
            classSession.current = nil
        }
        .accessibilityHint("Go back")
    }

    private func menuButton(anchor: MenuAnchor) -> some View {
        toolbarCircleButton(
            title: "Add",
            systemImage: "ellipsis"
        ) {
            toggleMenu(from: anchor)
        }
        .accessibilityHint(menuAnchor == anchor ? "Closes the menu" : "Opens the menu")
    }

    private func toolbarCircleButton(
        title: String,
        systemImage: String,
        foreground: Color = .primary,
        size: CGFloat = 35,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: size/3.0))
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuRow("New Item", systemImage: "plus") {
                print("New Item")
            }
            menuRow("Share", systemImage: "square.and.arrow.up") {
                print("Share")
            }
            Divider()
                .padding(.vertical, 4)
            menuRow("Settings", systemImage: "gearshape") {
                print("Settings")
            }
        }
        .padding(.vertical, 8)
        .frame(width: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.16), radius: 18, y: 8)
    }

    private func menuRow(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            dismissMenu()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.body.weight(.medium))
                    .frame(width: 22)
                Text(title)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func collapseDragGesture(restLength: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                collapseDrag = value.translation.height / max(restLength, 1)
            }
            .onEnded { value in
                finishCollapseDrag(
                    translation: value.translation.height,
                    velocity: value.velocity.height,
                    restLength: restLength
                )
            }
    }

    private func finishCollapseDrag(translation: CGFloat, velocity: CGFloat, restLength: CGFloat) {
        let length = max(restLength, 1)
        let current = collapseProgress + translation / length
        let projected = current + velocity / length * 0.25
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            collapseProgress = projected > 0.5 ? 1 : 0
            collapseDrag = 0
        }
    }

    private func toggleMenu(from anchor: MenuAnchor) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            menuAnchor = menuAnchor == anchor ? nil : anchor
        }
    }

    private func dismissMenu() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            menuAnchor = nil
        }
    }
}

private struct LocalCameraPreview: View {
    @ObservedObject var webRTCManager: WebRTCManager
    @Binding var videoSize: CGSize
    let minDim: CGFloat

    var body: some View {
        if let track = webRTCManager.localVideoTrack {
            VideoView(videoTrack: track, videoSize: $videoSize)
                .frame(width: minDim, height: minDim)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: minDim, height: minDim)
        }
    }
}

private struct CallMediaControls: View {
    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        HStack(spacing: 8) {
            mediaButton(
                title: webRTCManager.isMicrophoneEnabled ? "Disable Mic" : "Enable Mic",
                systemImage: webRTCManager.isMicrophoneEnabled ? "mic.fill" : "mic.slash.fill",
                foreground: webRTCManager.isMicrophoneEnabled ? .primary : .secondary
            ) {
                webRTCManager.setMicrophoneEnabled(!webRTCManager.isMicrophoneEnabled)
            }
            .accessibilityAddTraits(webRTCManager.isMicrophoneEnabled ? [.isSelected] : [])
            .accessibilityHint("Toggles mic on/off")

            mediaButton(
                title: webRTCManager.isCameraEnabled ? "Turn Camera Off" : "Turn Camera On",
                systemImage: webRTCManager.isCameraEnabled ? "video.fill" : "video.slash.fill",
                foreground: webRTCManager.isCameraEnabled ? .primary : .secondary
            ) {
                webRTCManager.setCameraEnabled(!webRTCManager.isCameraEnabled)
            }
            .accessibilityAddTraits(webRTCManager.isCameraEnabled ? [.isSelected] : [])
            .accessibilityHint("Toggles the camera")
        }
    }

    private func mediaButton(
        title: String,
        systemImage: String,
        foreground: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 20))
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .foregroundStyle(foreground)
                .frame(width: 60, height: 60)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    YView(
        myClass: MyClass(
            studentId: User.studentPreview.id!,
            instructorId: User.instructorPreview.id!,
            courseFormatId: CourseFormat.preview.id!
        ),
        user: User.studentPreview
    )
//        .environment(\.colorScheme, .dark)
}
