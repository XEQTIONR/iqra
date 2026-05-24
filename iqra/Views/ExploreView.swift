//
//  ExploreView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI
import CachedAsyncImage
struct ExploreView: View {
    var items = [1,2] // This represents the number of horizontal scroll items
    let imageUrls = [
        "https://picsum.photos/600/400",
        "https://picsum.photos/600/401",
        "https://picsum.photos/600/402",
        "https://picsum.photos/600/403",
        "https://picsum.photos/600/404"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            List {
//                ForEach(items, id: \.self) { _ in
                    VStack(spacing: 15) {
                        HStack {
                            Text("Read the Quran in Arabic")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(imageUrls, id: \.self) { url in
                                    Slide(url: .constant(url), width: .constant(geometry.size.width))
                                }
                            }
                            .scrollTargetLayout()
//                            .padding(.horizontal)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                    }
                    .padding(.horizontal, -5)
                    .listRowSeparator(.hidden)
                
                    VStack(spacing: 15) {
                        HStack {
                            Text("Quran Memorization Courses")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(imageUrls, id: \.self) { url in
                                    Slide(url: .constant(url), width: .constant(geometry.size.width))
                                }
                            }
                            .scrollTargetLayout()
    //                            .padding(.horizontal)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                    }
                    .padding(.horizontal, -5)
                    .listRowSeparator(.hidden)
                
                    VStack(spacing: 15) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Arabic Speaking Courses")
                                    .font(.headline)
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                       
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(imageUrls, id: \.self) { url in
                                    Slide(url: .constant(url), width: .constant(geometry.size.width))
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .safeAreaPadding(.horizontal, 0)
                }
//                .padding(.horizontal, -5)
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .listRowSpacing(30)
        }
    }
}

#Preview {
    ExploreView()
}
