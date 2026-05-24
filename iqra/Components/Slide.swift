//
//  Slide.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-23.
//

import SwiftUI

struct Slide: View {
    var title: String
    var url: String
    var width: CGFloat
    
    var body: some View {
        VStack {
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
            
            HStack {
                Text(title)
                    .foregroundStyle(.black)
                Spacer()
            }
        }
        
    }
}

#Preview {
    Slide(title: "A dummy title", url: "https://picsum.photos/600/400", width: 600 )
}
