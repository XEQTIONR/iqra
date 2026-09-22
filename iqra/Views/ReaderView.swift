//
//  ReaderView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import WrapLayout

struct ReaderView: View {
    // PostScript names (not file names). Verified via the font's `name` table.
    private static let uthmanicFontName = "KFGQPCUthmanicScriptHAFS" // KFGQPC ... HAFS Regular.otf

    var onDraw: ((UserPath) -> Void)? = nil
    var remotePaths: [UserPath] = []

    @State private var identifiablePaths: [UserPath] = []
    @State private var currentPath = UserPath()
    @State private var canDraw = false
    @State private var ingestedRemoteIDs: Set<UUID> = []

    private var isPathCanvasAnimating: Bool {
        identifiablePaths.contains { $0.isAnimating(at: Date()) }
    }

    var body: some View {
        let surahs: [Surah] = JSONService.loadLocalJSON(fileName: "quran-full-tashkeel") ?? []
        let surah = surahs[0]
        let verses = surah.verses

        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        Text(surah.name)
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(verses.indices, id: \.self) { index in
                                let words = verses[index].text.split(separator: " ")
                                WrapLayout {
                                    ForEach(words, id: \.self) { word in
                                        HStack {
                                            Text(word)
                                                .font(.custom(Self.uthmanicFontName, size: 34))
                                                .foregroundStyle(.primary)
                                                .padding(.horizontal, 5)
                                                .opacity(1)
                                        }
                                    }
                                    VStack(alignment: .center) {
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(lineWidth: 1)
                                                    .frame(width: 25, height: 25)
                                            )
                                    }
                                    .padding(.top, 25)
                                    .padding(.leading, 20)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .environment(\.layoutDirection, .rightToLeft)
                        .padding()
                    }
                    .background(Color.secondary)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            canDraw.toggle()
                        }) {
                            Image(systemName: "gear")
                                .renderingMode(.original)
                        }
                    }
                }
                .overlay {
                    drawingOverlay(scrollProxy: proxy)
                }
                .onAppear { ingestRemotePaths(remotePaths) }
                .onChange(of: remotePaths) { _, newPaths in
                    ingestRemotePaths(newPaths)
                }
            }
        }
        
    }

    private func drawingOverlay(scrollProxy: ScrollViewProxy) -> some View {
        GeometryReader { geometry in
            ZStack {
                if canDraw || !identifiablePaths.isEmpty {
                    TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !isPathCanvasAnimating)) { timeline in
                        Canvas { context, _ in
                            let now = timeline.date
                            for path in identifiablePaths {
                                path.draw(into: context, at: now)
                            }
                            if canDraw {
                                currentPath.draw(into: context, at: now)
                            }
                        }
                        .gesture(canDraw ? drawGesture(scrollProxy: scrollProxy) : nil)
                        .allowsHitTesting(canDraw)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }

    private func drawGesture(scrollProxy: ScrollViewProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                currentPath.addPoint(value.location)
                if value.translation.width > 100 {
                    withAnimation { scrollProxy.scrollTo(value.translation.width, anchor: .top) }
                } else if value.translation.width < -100 {
                    withAnimation { scrollProxy.scrollTo(value.translation.width, anchor: .top) }
                }
            }
            .onEnded { _ in
                var finished = currentPath
                finished.finish(color: .blue)
                identifiablePaths.append(finished)
                onDraw?(finished)
                currentPath = UserPath()
                scheduleFade(for: finished)
            }
    }

    private func ingestRemotePaths(_ paths: [UserPath]) {
        for path in paths where ingestedRemoteIDs.insert(path.id).inserted {
            let incoming = path.replaying(from: Date())
            identifiablePaths.append(incoming)
            scheduleFade(for: incoming)
        }
    }

    private func scheduleFade(for path: UserPath) {
        let pathID = path.id
        Task { @MainActor in
            let holdTime = (path.replayStartedAt == nil ? 0 : path.strokeDuration) + path.fadeDelay
            try? await Task.sleep(for: .seconds(holdTime))
            guard let index = identifiablePaths.firstIndex(where: { $0.id == pathID }) else { return }
            identifiablePaths[index].beginFade()
            try? await Task.sleep(for: .seconds(path.fadeDuration))
            identifiablePaths.removeAll { $0.id == pathID }
        }
    }
}

#Preview {
    ReaderView()
}
