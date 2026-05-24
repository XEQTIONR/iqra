//
//  Slide.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-23.
//

import SwiftUI

struct Slide: View {
    
    @Binding var url: String
    @Binding var width: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.gray
        }
        .frame(width: width * 0.8,
               height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    Slide(url: .constant("https://picsum.photos/600/400"), width: .constant(600.0))
}
