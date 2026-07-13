//
//  CourseVariantForm.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-06-12.
//

import SwiftUI

struct CourseFormatForm: View {

    @Binding var formData: Course
    @Binding var videoUrl: URL?
    @Binding var image: UIImage?
    var onComplete: ((_ course: Course) -> Void)? = nil
    @State private var options: [CourseFormat]

    init(
        formData: Binding<Course>,
        videoUrl: Binding<URL?>,
        image: Binding<UIImage?>,
        onComplete: ((_ course: Course) -> Void)? = nil
    ) {
        self._formData = formData
        self._videoUrl = videoUrl
        self._image = image
        self.onComplete = onComplete

        let totalLessons = formData.wrappedValue.lengthType == .fixed ? 10 : 0
        self._options = State(initialValue: [
            CourseFormat(
                title: "1 day trial",
                description: "Try our 1 day trial",
                unit: .lesson,
                lessonLength: 60,
                lessonsPerWeek: 1,
                totalLessons: 1,
                price: 0,
                billingCycles: 1
            ),
            CourseFormat(
                title: "Weekly",
                description: "2 classes a week",
                unit: .week,
                lessonLength: 60,
                lessonsPerWeek: 2,
                totalLessons: totalLessons,
                price: 0,
                billingCycles: 0
            ),
        ])
    }
    
    private var continueRow: some View {
        Button("Save") {
            Task {
                do {
                    let serverURL = URL(string: UPLOADS_ENDPOINT)!
                    let (videoData, _, ok1) = try await RequestService.uploadFileUrl(videoUrl!, serverURL: serverURL, fieldName: "file")
                    
                    if !ok1 {
                        print("Error1")
                        // @TODO: error handle here
                        return
                    }
                    
                    let (imageData, _, ok2) = try await RequestService.uploadImage(image!, serverURL: serverURL, fieldName: "file")
                    
                    if !ok2 {
                        print("Error2")
                        // @TODO: error handle here
                        return
                    }

                    let video = try RequestService.apiUnwrapData(type: File.self, from: videoData)
                    let image = try RequestService.apiUnwrapData(type: File.self, from: imageData)
                    
                    formData.video = video.path
                    formData.image = image.path
                    formData.formats = options
                    
                    print("formData", formData)
                    
                    let (data,resp,ok) = try await RequestService.request(
                        COURSES_ENDPOINT,
                        method: "POST",
                        headers: RequestService.authJsonHeaders,
                        body: JSONEncoder().encode(formData)
                    )
                    
                    print(data)
                    print(String(data:data, encoding: .utf8)!)
                    
                    if !ok {
                        print ("Error3")
                        print(String(data: data, encoding: .utf8)!)
                        print(resp)
                        //@TODO: error handle
                        return
                    }
                    
                    let course = try RequestService.apiUnwrapData(type: Course.self, from: data)
                    onComplete?(course)
                } catch {
                    print(error)
                    // @TODO: Error handle here
                }
            }
        }
    }
    
    private func formatSection(_ index: Int) -> some View {
        Section(header: Text("Format \(index + 1)")) {
            HStack {
                TextField("Title", text: $options[index].title)
                Button(role: .destructive) {
                    // Perform data deletion or destructive task here
                    if options.count > 1 {
                        options.remove(at: index)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                }
            }
            TextField("Description", text: $options[index].description, axis: .vertical)

            Stepper("Lesson length: \(options[index].lessonLength) min", value: $options[index].lessonLength, in: 0...240, step: 15)
            Stepper("Classes per week: \(options[index].lessonsPerWeek)", value: $options[index].lessonsPerWeek, in: 0...14)
            
            if formData.lengthType == .fixed {
                Stepper("Total lessons: \(options[index].totalLessons)", value: $options[index].totalLessons, in: 0...100, step: 1)
            }

            HStack {
                Text("Price")
                Spacer()
                TextField("0", value: $options[index].price, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                Text("/ \(options[index].unit.rawValue.capitalized)")
                    .foregroundColor(.secondary)
            }

            Picker("Billing unit", selection: $options[index].unit) {
                ForEach(BillingUnit.allCases, id: \.self) { period in
                    Text(period.rawValue.capitalized).tag(period)
                }
            }
        }
    }

    private func addFormat() {
        options.append(
            CourseFormat(
                title: "",
                description: "",
                unit: .week,
                lessonLength: 60,
                lessonsPerWeek: 1,
                totalLessons: formData.lengthType == .fixed ? 10 : 0,
                price: 0,
                billingCycles: 1
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(options.indices, id: \.self) { index in
                    formatSection(index)
                }
                .onDelete { options.remove(atOffsets: $0) }

                Button {
                    addFormat()
                } label: {
                    Label("Add variant", systemImage: "plus")
                }

                continueRow
            }
            .navigationTitle("Course formats")
        }
    }
}

#Preview {
    CourseFormatForm(
        formData: .constant(Course(
            title: "Test",
            description: "The description of this course",
            image: "",
            video: "",
            difficulty: .advanced,
            category: .reading,
            lengthType: .fixed,
            ageGroups: [.kids, .teens]
        )),
        videoUrl: .constant(URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!),
        image: .constant(nil),
        onComplete: nil,
    )
}
