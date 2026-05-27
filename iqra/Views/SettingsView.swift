//
//  SettingsView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import WrapLayout
//import UserPath

struct SettingsView: View {
    // PostScript names (not file names). Verified via the font's `name` table.
    private static let uthmanicFontName = "KFGQPCUthmanicScriptHAFS" // KFGQPC ... HAFS Regular.otf
    
    // Store all completed drawing paths with unique IDs for animation
    @State private var identifiablePaths: [IdentifiableUserPath] = []
    // Store the current in-progress path
    @State private var currentPath = UserPath(points: [])
    @State private var canDraw = true
    // Trigger for canvas redraw
    @State private var redrawTrigger = false
    
    var body: some View {
        let surahs: [Surah] = JSONService.loadLocalJSON(fileName: "quran-full-tashkeel") ?? []
        let surah = surahs[0]
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
                .frame(height: .infinity)
                .background(Color.gray.opacity(0.1))
                
                Spacer()
            }
            .overlay(
                ZStack {
                    if canDraw {
                        Canvas { context, size in
                            // Draw all completed paths
                            for identifiablePath in identifiablePaths {
                                let opacity = identifiablePath.opacity
                                var contextCopy = context
                                contextCopy.opacity = opacity
                                contextCopy.stroke(Path(identifiablePath.path.cgPath), with: .color(.blue), lineWidth: 5)
                            }
                            // Draw the current in-progress path
                            context.stroke(Path(currentPath.cgPath), with: .color(.red), lineWidth: 5)
                        }
                        .id(redrawTrigger) // Force redraw when trigger changes
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    print("onChanged")
                                    print(value)
                                    // Add the new touch location to the current path
                                    currentPath.points.append(value.location)
                                    if value.translation.width > 100 {
                                        withAnimation { proxy.scrollTo(value.translation.width, anchor: .top) }
                                    } else if value.translation.width < -100 {
                                        withAnimation { proxy.scrollTo(value.translation.width, anchor: .top) }
                                    }
                                }
                                .onEnded { _ in
                                    // Create a new identifiable path from the completed drawing
                                    let newIdentifiablePath = IdentifiableUserPath(path: currentPath, opacity: 1.0)
                                    
                                    // Add to the collection
                                    identifiablePaths.append(newIdentifiablePath)
                                    
                                    // Reset current path for the next drawing
                                    currentPath = UserPath(points: [])
                                    
                                    // Schedule fade-out after 2 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        if let index = identifiablePaths.firstIndex(where: { $0.id == newIdentifiablePath.id }) {
                                            // Animate the opacity change
                                            withAnimation(.easeOut(duration: 0.5)) {
                                                identifiablePaths[index].opacity = 0.0
                                                redrawTrigger.toggle() // Force canvas to redraw with new opacity
                                            }
                                            
                                            // Remove after fade completes
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                if let removeIndex = identifiablePaths.firstIndex(where: { $0.id == newIdentifiablePath.id }) {
                                                    identifiablePaths.remove(at: removeIndex)
                                                    redrawTrigger.toggle()
                                                }
                                            }
                                        }
                                    }
                                }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        }
                        Spacer()
                    }
                }
            )
        }
    }
}

// UserPath struct to store drawing points
struct UserPath: Equatable {
    var points: [CGPoint]
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        guard let firstPoint = points.first else { return path }
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
    
    static func == (lhs: UserPath, rhs: UserPath) -> Bool {
        return lhs.points == rhs.points
    }
}

// Wrapper struct to give each path a unique ID for animation
class IdentifiableUserPath: Identifiable, Equatable {
    let id = UUID()
    let path: UserPath
    var opacity: Double
    
    init(path: UserPath, opacity: Double) {
        self.path = path
        self.opacity = opacity
    }
    
    static func == (lhs: IdentifiableUserPath, rhs: IdentifiableUserPath) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    SettingsView()
}
