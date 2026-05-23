//
//  ReliableAsyncImage.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-23.
//

import SwiftUI

struct ReliableAsyncImage: View {
    
    let url: URL?
    
    @State private var loadUrl: URL? = nil
    
    var body: some View {
        AsyncImage(url: loadUrl) { phase in
            switch phase {
                case .success(let image):
                    image.resizable()
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
            }
        }
        .onAppear {
            loadUrl = url
        }
        .onDisappear {
            loadUrl = nil
        }
    }
}

#Preview {
    ReliableAsyncImage(url: URL(string: "https://picsum.photos/600/200"))
}
