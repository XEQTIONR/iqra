//
//  UserPath.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-18.
//

import SwiftUI

/// A single sample along a stroke, with the time it was drawn relative to the stroke start.
struct PathSample: Equatable {
    var location: CGPoint
    /// Seconds since `UserPath.startedAt`.
    var offset: TimeInterval
}

/// A freehand stroke that can be redrawn later, including animated replay and fade.
struct UserPath: Identifiable, Equatable {
    let id: UUID
    var samples: [PathSample]
    var startedAt: Date
    var completedAt: Date?

    var color: Color
    var lineWidth: CGFloat
    var lineCap: CGLineCap
    var lineJoin: CGLineJoin

    /// Seconds after completion before a fade begins.
    var fadeDelay: TimeInterval
    var fadeDuration: TimeInterval
    /// When set, `opacity(at:)` interpolates from 1 to 0 over `fadeDuration`.
    var fadeStartedAt: Date?

    /// When set, `displayedCGPath(at:)` reveals the stroke over its original timing.
    var replayStartedAt: Date?

    init(
        id: UUID = UUID(),
        samples: [PathSample] = [],
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        color: Color = .red,
        lineWidth: CGFloat = 5,
        lineCap: CGLineCap = .round,
        lineJoin: CGLineJoin = .round,
        fadeDelay: TimeInterval = 5,
        fadeDuration: TimeInterval = 0.5,
        fadeStartedAt: Date? = nil,
        replayStartedAt: Date? = nil
    ) {
        self.id = id
        self.samples = samples
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.color = color
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.fadeDelay = fadeDelay
        self.fadeDuration = fadeDuration
        self.fadeStartedAt = fadeStartedAt
        self.replayStartedAt = replayStartedAt
    }

    var strokeDuration: TimeInterval {
        samples.last?.offset ?? 0
    }

    var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, lineJoin: lineJoin)
    }

    var cgPath: CGPath {
        cgPath(progress: 1)
    }

    mutating func addPoint(_ location: CGPoint, at date: Date = Date()) {
        if samples.isEmpty {
            startedAt = date
            samples.append(PathSample(location: location, offset: 0))
            return
        }
        samples.append(PathSample(location: location, offset: date.timeIntervalSince(startedAt)))
    }

    mutating func finish(at date: Date = Date(), color: Color? = nil) {
        completedAt = date
        if let color {
            self.color = color
        }
    }

    mutating func beginFade(at date: Date = Date()) {
        fadeStartedAt = date
    }

    func replaying(from date: Date) -> UserPath {
        var copy = self
        copy.replayStartedAt = date
        copy.fadeStartedAt = nil
        return copy
    }

    /// 0...1 through the original stroke timing. Values outside that range are clamped.
    func strokeProgress(at date: Date, from replayStart: Date) -> CGFloat {
        guard strokeDuration > 0 else { return 1 }
        let elapsed = date.timeIntervalSince(replayStart)
        return CGFloat(min(max(elapsed / strokeDuration, 0), 1))
    }

    func displayedCGPath(at date: Date) -> CGPath {
        guard let replayStartedAt else { return cgPath }
        return cgPath(progress: strokeProgress(at: date, from: replayStartedAt))
    }

    /// Builds the stroke up to `progress` (0 = empty, 1 = complete), interpolating the last segment.
    func cgPath(progress: CGFloat) -> CGPath {
        let path = CGMutablePath()
        guard let first = samples.first else { return path }

        let clamped = min(max(progress, 0), 1)
        path.move(to: first.location)

        if clamped >= 1 || samples.count == 1 {
            for sample in samples.dropFirst() {
                path.addLine(to: sample.location)
            }
            return path
        }

        let targetTime = strokeDuration * TimeInterval(clamped)
        for (previous, next) in zip(samples, samples.dropFirst()) {
            if next.offset <= targetTime {
                path.addLine(to: next.location)
                continue
            }

            let span = next.offset - previous.offset
            let t = CGFloat(span > 0 ? (targetTime - previous.offset) / span : 1)
            path.addLine(
                to: CGPoint(
                    x: previous.location.x + (next.location.x - previous.location.x) * t,
                    y: previous.location.y + (next.location.y - previous.location.y) * t
                )
            )
            break
        }
        return path
    }

    func opacity(at date: Date) -> Double {
        guard let fadeStartedAt else { return 1 }
        let elapsed = date.timeIntervalSince(fadeStartedAt)
        if elapsed <= 0 { return 1 }
        if elapsed >= fadeDuration { return 0 }
        let linear = elapsed / fadeDuration
        let easeOut = 1 - pow(1 - linear, 2)
        return 1 - easeOut
    }

    func isFading(at date: Date) -> Bool {
        guard let fadeStartedAt else { return false }
        let elapsed = date.timeIntervalSince(fadeStartedAt)
        return elapsed >= 0 && elapsed < fadeDuration
    }

    func isReplaying(at date: Date) -> Bool {
        guard let replayStartedAt else { return false }
        return strokeProgress(at: date, from: replayStartedAt) < 1
    }

    func isAnimating(at date: Date) -> Bool {
        isFading(at: date) || isReplaying(at: date)
    }

    func draw(into context: GraphicsContext, at date: Date) {
        var context = context
        context.opacity = opacity(at: date)
        context.stroke(Path(displayedCGPath(at: date)), with: .color(color), style: strokeStyle)
    }
}
