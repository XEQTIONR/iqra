//
//  ClassSessionView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-09-01.
//

import SwiftUI
import WebRTC

struct ClassSessionView: View {

    private enum MenuAnchor {
        case top
        case bottom
    }
    
    @Environment(ClassSession.self) private var classSession
    
    private let appUser: User
    private let myClass: MyClass
    private let remoteVideoScaleFactor: CGFloat = 300
    
    @State private var canDrag = false
    @State private var canDraw = false
    @State private var collapseDrag: CGFloat = 1 //minmax 0 or 1
    @State private var collapseProgress: CGFloat = 1 //minmax 0 or 1
    @State private var dragStart: CGPoint?
    @State private var isCollapsed: Bool = true
    @State private var isLive: Bool = false
    @State private var isLocalAudioOn: Bool = false
    @State private var isLocalPreviewOn: Bool = false
    @State private var isPeerConnected: Bool = false
    @State private var menuAnchor: MenuAnchor?
    @State private var remoteVideoPosition = CGPoint(x: 50, y: 50)
    @State private var splitRestLength: CGFloat = 300
    @State private var showSettings: Bool = false
    @State private var targetUserId: String
    @State private var userId: String
    @State private var videoSize = CGSize(width: 9, height: 16)
    @State private var webRTCManager: WebRTCManager?
    
    /// Camera buffers are often landscape; swap so the preview matches the container.
    private func videoFrameSize(in containerSize: CGSize) -> CGFloat {
        
        enum Dim {
            case width
            case height
        }
        
        let shortDim = containerSize.width < containerSize.height ? Dim.width : Dim.height
        
        return shortDim == Dim.width ? containerSize.width : containerSize.height
    }

    private var displayedCollapse: CGFloat {
        min(max(collapseProgress + collapseDrag, 0), 1)
    }

    var r1: some View {
        GeometryReader { geo in
            let minDim = min(geo.size.width, geo.size.height)
            
            
            if isLive {
                ZStack {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(.gray)
                                .frame(width: 50, height: 50)

                            Text("S")
                                .font(.system(size: 12, weight: .bold, design: .default))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)

                    if let webRTCManager {
                        ObservedVideoTrackView(
                            webRTCManager: webRTCManager,
                            videoSize: $videoSize,
                            isRemote: true
                        )
                    }
                }
            }
            else {
                VStack() {
                    Spacer()

                    if let webRTCManager, isLocalPreviewOn {
                        LocalCameraPreview(
                            webRTCManager: webRTCManager,
                            videoSize: $videoSize,
                            width: minDim,
                            height: minDim
                        )
                    } else {
                        Rectangle()
                            .fill(Color.purple.opacity(0.4))
                            .frame(width: minDim, height: minDim)
                    }

                    Spacer()
                    
                    VStack(spacing: 10) {
                        HStack {
                            Button("Join with audio", systemImage: isLocalAudioOn ? "mic.slash.fill" : "mic.fill") {
                                isLocalAudioOn.toggle()
                                startWebRTCIfNeeded(captureMode: .audioOnly)
                            }
                            .filledBackground()
                            
                            Button("Join with video", systemImage: isLocalPreviewOn ? "video.slash.fill" : "video.fill") {
                                startWebRTCIfNeeded(captureMode: .video)
                                
                                if !isLocalPreviewOn {
                                    isLocalPreviewOn.toggle() // true
                                    webRTCManager?.setMicrophoneEnabled(true)
                                    isLocalAudioOn = true
                                } else {
                                    isLocalPreviewOn.toggle() // false
                                    webRTCManager?.setMicrophoneEnabled(false)
                                    isLocalAudioOn = false
                                }
                                
                            }
                            .filledBackground()
                        }
                        
                        Button("Join") {
                            print("Join")
                            guard isLocalAudioOn else {
                                print("Guard failed audio: \(isLocalAudioOn), video: \(isLocalPreviewOn)")
                                return
                            }
                            
                            if !isLocalPreviewOn {
                                webRTCManager?.setCaptureMode(.audioOnly)
                            } else {
                                webRTCManager?.setCaptureMode(.video)
                            }
                            webRTCManager?.setMicrophoneEnabled(true)
                            
                            startWebRTCIfNeeded(captureMode: isLocalPreviewOn ? .video : .audioOnly)
                            
                            guard let webRTCManager else {
                                print("WebRTCManager is missing")
                                return
                            }
                            guard let userId = appUser.id else {
                                print("User not found \(userId)")
                                return
                            }
                            
                            webRTCManager.connect(userId: String(userId), classId: myClass.id)
                            
                            isLive = true
                            canDrag = true
                            setR2Collapsed(false)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                //canDrag = false
                            }
                        }
                        .filledBackground()
                        .disabled(webRTCManager == nil)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 75)
                    
                }
                .ignoresSafeArea(edges: .bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.pink)
            }
        }
    }

    var r2: some View {
        GeometryReader { geo in
            if let webRTCManager, isLive {
                ObservedVideoTrackView(
                    webRTCManager: webRTCManager,
                    videoSize: $videoSize,
                    isRemote: false
                )
            }
        }
    }
    
    init(myClass: MyClass, user: User) {
        
        self.myClass = myClass
        self.appUser = user
        
        if appUser.id == myClass.studentId {
            _userId = State(initialValue: String(myClass.studentId))
            _targetUserId = State(initialValue: String(myClass.instructorId))
        } else { // appUser.id == myClass.instructorId
            _userId = State(initialValue: String(myClass.instructorId))
            _targetUserId = State(initialValue: String(myClass.studentId))
        }
    }

    private func startWebRTCIfNeeded(captureMode: WebRTCManager.MediaCaptureMode) {
        guard webRTCManager == nil else { return }
        let manager = WebRTCManager(captureMode: captureMode)
        
        manager.onGuestJoin = { [weak manager] idStr in
            print("Guest joined: \(idStr). Starting call...")
            isPeerConnected = true
            manager?.startCall(to: idStr)
        }
        manager.onGuestLeave = { [weak manager] idStr in
            print("Guest left: \(idStr). Hanging up...")
            isPeerConnected = false
            manager?.hangUp() //:)
        }
        
        print("Setting web RTC manager")
        webRTCManager = manager
    }

    var body: some View {
        NavigationStack {
            VStack {
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
                                .gesture(
                                    canDrag && progress > 0.02
                                        ? collapseDragGesture(restLength: restLength)
                                        : nil
                                )

                            r2
                                .frame(width: r2Size.width, height: r2Size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .offset(x: r2Offset.width, y: r2Offset.height)
                                .contentShape(Rectangle())
                                .highPriorityGesture(
                                    canDrag && progress < 0.98
                                        ? collapseDragGesture(restLength: restLength)
                                        : nil
                                )
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
            .sheet(isPresented: $showSettings) {
                ReaderView(onDraw: { path in
                    
                    guard let webRTCManager else { return }
                     
                    webRTCManager.sendPath(path: path)
                    print("Draw Path:")
                    print(path)
                })
            }
            
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
            leaveSession()
        }
        .accessibilityHint("Go back")
    }

    private func leaveSession() {
        webRTCManager?.shutdown()
        webRTCManager = nil
        
        isLocalAudioOn = false
        isPeerConnected = false
        classSession.current = nil
        isLive = false
        isLocalPreviewOn = false
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
                showSettings.toggle()
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
        setR2Collapsed(projected > 0.5)
    }

    private func setR2Collapsed(_ collapsed: Bool) {
        isCollapsed = collapsed
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            collapseProgress = collapsed ? 1 : 0
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

private struct ObservedVideoTrackView: View {
    @ObservedObject var webRTCManager: WebRTCManager
    @Binding var videoSize: CGSize
    let isRemote: Bool

    var body: some View {
        if let track = isRemote ? webRTCManager.remoteVideoTrack : webRTCManager.localVideoTrack {
            VideoView(videoTrack: track, videoSize: $videoSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
    }
}

private struct LocalCameraPreview: View {
    @ObservedObject var webRTCManager: WebRTCManager
    @Binding var videoSize: CGSize
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let track = webRTCManager.localVideoTrack {
            VideoView(videoTrack: track, videoSize: $videoSize)
                .frame(width: width, height: height)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: width, height: height)
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
    ClassSessionView(
        myClass: MyClass(
            studentId: User.studentPreview.id!,
            instructorId: User.instructorPreview.id!,
            courseFormatId: CourseFormat.preview.id!
        ),
        user: User.studentPreview
    )
    .environment(ClassSession(MyClass.preview))
//        .environment(\.colorScheme, .dark)
}
