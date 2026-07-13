//
//  CourseView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-24.
//

import SwiftUI

struct CourseView: View {
    let course: Course
    @State private var isExpanded: Bool = false
    @State private var i = 0

    var body: some View {
        VStack {
            courseImage
            courseContent
            Spacer()
        }
    }

    private var courseImage: some View {
        AsyncImage(url: URL(string: course.image)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Color.gray
        }
    }

    private var courseContent: some View {
        VStack(spacing: 50) {
            courseDetails
            enrollmentSection
        }
        .padding()
    }

    private var courseDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(course.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(course.description)
                .foregroundStyle(.secondary)

            metadataRow(
                leading: ("Difficulty:", course.difficulty.rawValue.capitalized),
                trailing: ("Category:", course.category.rawValue.capitalized)
            )

            HStack {
                HStack {
                    Text("Age Groups:")
                        .fontWeight(.semibold)
                    Text(course.ageGroups.map({ $0.rawValue.capitalized }).joined(separator: ", "))
                    Spacer()
                }
                .containerRelativeFrame(.horizontal) { length, axis in
                    length * 0.45
                }
                HStack {
                    Text("Length Type:")
                        .fontWeight(.semibold)
                    Text(course.lengthType.rawValue.capitalized)
                    Spacer()
                }
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metadataRow(
        leading: (label: String, value: String),
        trailing: (label: String, value: String)
    ) -> some View {
        HStack {
            HStack {
                Text(leading.label)
                    .fontWeight(.semibold)
                Text(leading.value)
                Spacer()
            }
            .containerRelativeFrame(.horizontal) { length, axis in
                length * 0.45
            }
            Spacer()
            HStack {
                Text(trailing.label)
                    .fontWeight(.semibold)
                Text(trailing.value)
                Spacer()
            }
            .containerRelativeFrame(.horizontal) { length, axis in
                length * 0.45
            }
        }
        .font(.caption)
    }

    private var enrollmentSection: some View {
        DisclosureGroup("Enroll in this course", isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(0..<(course.formats ?? []).count, id: \.self) { index in
                    formatRow(at: index)
                }

                NavigationLink {
                    CourseScheduleView(
                        format: (course.formats ?? [])[i],
                        course: course
                    )
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.all, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.top)
        }
    }

    private func formatRow(at index: Int) -> some View {
        let format = (course.formats ?? [])[index]
        let isSelected = i == index

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(format.title)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Circle()
                    .fill(isSelected ? .blue : .secondary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(.white)
                                .frame(width: 12, height: 12)
                        }
                    }
            }

            Text("$ \(format.price) per \(format.unit)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(format.description)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            i = index
        }
        .padding()
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? .blue : .secondary, lineWidth: 1)
        )
    }
}

#Preview {
    CourseView(course: Course(
        id: 1,
        title: "My Course",
        description: "A dummy description", image: "https://picsum.photos/600/400",
        video: "",
        difficulty: .beginner,
        category: .reading,
        lengthType: .fixed,
        ageGroups: [.kids, .teens],
        isPublished: true,
        formats: [
            CourseFormat(
                title: "Format title",
                description: "A 1-week trial that can to give this a go",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 2,
                totalLessons: 10,
                price: 50,
                billingCycles: 10

            ),
            CourseFormat(
                title: "Format title 2",
                description: "A 1-week trial that can to give this a go",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 2,
                totalLessons: 10,
                price: 50,
                billingCycles: 10

            )
        ]
    ))
}
