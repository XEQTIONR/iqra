//
//  IntroView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-22.
//

import SwiftUI

struct IntroView: View {
    
    @Binding var currentSection: ContentSection
    
    let items = [1,2,3]
    
    init(currentSection: Binding<ContentSection>) {
        self._currentSection = currentSection
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
    }
    
    var body: some View {
        TabView {
            ForEach(items, id: \.self) { item in
                RoundedRectangle(cornerRadius: 20)
                    .fill(.background)
                    .overlay(VStack {
                        if (item != 3) {
                            Spacer()
                            Text("Page \(item)")
                                .font(.largeTitle)
                            Spacer()
                        } else {
                            Spacer()
                            Text("Page \(item)")
                                .font(.largeTitle)
                            Spacer()
                            Button("Start") {
                                currentSection = .main
                            }.padding(.bottom, 50)
                        }
                    })
                    .padding()
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    @Previewable @State var section: ContentSection = .intro
    IntroView(currentSection: $section)
}
