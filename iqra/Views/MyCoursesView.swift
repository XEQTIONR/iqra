//
//  MyCoursesView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-07.
//

import SwiftUI

struct MyCoursesView: View {
    
    @State var showNewCourseSheet: Bool = false
    
    var body: some View {
        Text("My Courses View")
            .sheet(isPresented: $showNewCourseSheet) {
                CourseForm()
            }
    }
}

#Preview {
    MyCoursesView()
}
