//
//  Button+Background.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-09-09.
//

import SwiftUI

private struct FilledButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
            configuration.title
        }
    }
}

private struct FilledButtonStyle<Fill: ShapeStyle>: ButtonStyle {
    var fill: Fill
    var cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        configuration.label
            .labelStyle(FilledButtonLabelStyle())
            .font(.body.weight(.medium))
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(fill, in: shape)
            .contentShape(shape)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension Button where Label: View {
    func filledBackground(
        _ fill: some ShapeStyle = .black,
        cornerRadius: CGFloat = 8
    ) -> some View {
        buttonStyle(FilledButtonStyle(fill: fill, cornerRadius: cornerRadius))
    }
}
