//
//  ExperimentView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-08-18.
//

import SwiftUI

struct ExperimentView: View {
    var body: some View {
        GeometryReader { geometry in
            Text("\(geometry.size.width) x \(geometry.size.height)")
                .font(.title)
        }
    }
}

#Preview {
    ExperimentView()
}
