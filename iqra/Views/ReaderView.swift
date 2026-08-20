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

    @State private var identifiablePaths: [UserPath] = []
    @State private var currentPath = UserPath()
    @State private var canDraw = true

    private var isPathCanvasAnimating: Bool {
        identifiablePaths.contains { $0.isAnimating(at: Date()) }
    }

    var body: some View {
        let surahs: [Surah] = JSONService.loadLocalJSON(fileName: "quran-full-tashkeel") ?? []
        let surah = surahs[1]
        let verses = surah.verses

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
                                            .padding(.horizontal, 5)
                                            .opacity(0)
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
            }
            .overlay {
                drawingOverlay(scrollProxy: proxy)
            }
        }
    }

    private func drawingOverlay(scrollProxy: ScrollViewProxy) -> some View {
        GeometryReader { geometry in
            ZStack {
                if canDraw {
                    TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: !isPathCanvasAnimating)) { timeline in
                        Canvas { context, _ in
                            let now = timeline.date
                            for path in identifiablePaths {
                                path.draw(into: context, at: now)
                            }
                            currentPath.draw(into: context, at: now)
                        }
                        .gesture(drawGesture(scrollProxy: scrollProxy))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    Text(String(format: "%.2f x %.2f", geometry.size.width, geometry.size.height))
                }

                VStack {
                    HStack {
                        Spacer()
                        Button("Tap Me!") {
                            withAnimation {
                                canDraw = !canDraw
                            }
                        }
                        .padding()
                        Text(String(format: "%.2f x %.2f", geometry.size.width, geometry.size.height))
                            .font(.caption)
                    }
                    Spacer()
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

    private func scheduleFade(for path: UserPath) {
        let pathID = path.id
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(path.fadeDelay))
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
