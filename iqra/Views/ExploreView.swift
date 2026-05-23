//
//  ExploreView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import CachedAsyncImage

struct ExploreView: View {
    var itms = [1,2,3,4,5,6,7,8,9,10]
    var body: some View {
        
        
        List {
            ForEach(itms, id: \.self) { item in
                CachedAsyncImage(url: URL(string: "https://picsum.photos/600/200"))
            }
        }
        
        .ignoresSafeArea(edges: .horizontal)
        .listStyle(PlainListStyle())
        .listRowInsets(EdgeInsets())
        
        
    }
}

#Preview {
    ExploreView()
}
