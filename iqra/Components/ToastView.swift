//
//  ToastView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-07-23.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
            )
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                if isShowing {
                    ToastView(message: message)
                        .padding(.top, 20)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                }
                Spacer()
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
}

extension View {
    func toast(isShowing: Binding<Bool>,
               message: String,
               duration: TimeInterval = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, duration: duration))
    }
}

#Preview {
    ToastView(message: "The toast message")
}
