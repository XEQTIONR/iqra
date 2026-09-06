//
//  YView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-09-01.
//

import SwiftUI

struct YView: View {
    @State private var isMenuPresented = false
    @State private var isCameraOn = true
    @State private var canDraw = false

    var r1: some View {
        VStack {
            Text("Hello")
        }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.red.opacity(0.5))
    }

    var r2: some View {
        VStack {
            Text("Hello2")
        }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.teal.opacity(0.5))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geo in
                    let isLandscape = geo.size.width > geo.size.height
                    let layout = isLandscape
                        ? AnyLayout(HStackLayout(spacing: 0))
                        : AnyLayout(VStackLayout(spacing: 0))

                    layout {
                        r1
                        r2
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()

                if isMenuPresented {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissMenu()
                        }

                    dropdownMenu
                        .padding(.trailing, 12)
                        .padding(.top, 20)
                        .transition(
                            .scale(scale: 0.5, anchor: .topTrailing)
                            .combined(with: .opacity)
                        )
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        toolbarCircleButton(
                            title: isCameraOn ? "Turn Camera Off" : "Turn Camera On",
                            systemImage: isCameraOn ? "video.fill" : "video.slash.fill",
                            foreground: isCameraOn ? .accentColor : .secondary
                        ) {
                            isCameraOn.toggle()
                        }
                        .accessibilityAddTraits(isCameraOn ? [.isSelected] : [])
                        .accessibilityHint("Toggles the camera")

                        toolbarCircleButton(
                            title: "Add",
                            systemImage: "ellipsis"
                        ) {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                isMenuPresented.toggle()
                            }
                        }
                        .accessibilityHint(isMenuPresented ? "Closes the menu" : "Opens the menu")
                    }
                    .padding(.top, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    HStack(spacing: 8) {
                        toolbarCircleButton(
                            title: canDraw ? "Disabled Drawing" : "Disable Drawing",
                            systemImage: canDraw ? "pencil" : "pencil.slash",
                            foreground: canDraw ? .accentColor : .secondary
                        ) {
                            canDraw.toggle()
                        }
                        .accessibilityAddTraits(isCameraOn ? [.isSelected] : [])
                        .accessibilityHint("Toggles the camera")
                    }
                    .padding(.top, 20)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private func toolbarCircleButton(
        title: String,
        systemImage: String,
        foreground: Color = .primary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .foregroundStyle(foreground)
                .frame(width: 35, height: 35)
                .background(.ultraThinMaterial, in: Circle())
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

    private func dismissMenu() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            isMenuPresented = false
        }
    }
}

#Preview {
    YView()
}
