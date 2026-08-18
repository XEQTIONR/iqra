//
//  ZView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-17.
//

import SwiftUI

struct ZView: View {
    private let orangeSize: CGFloat = 100
    @State private var orangePosition = CGPoint(x: 50, y: 50)
    @State private var dragStart: CGPoint?

    var body: some View {
        ZStack {
            ReaderView()

            GeometryReader { geo in
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: orangeSize, height: orangeSize)
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
    ZView()
}
