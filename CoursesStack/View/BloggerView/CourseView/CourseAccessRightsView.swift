import SwiftUI

struct CourseAccessRightsView: View {
    @StateObject private var viewModel = CourseAccessRightsViewModel()

    var body: some View {
        VStack {
            if viewModel.courses.isEmpty {
                Text("Нет доступных курсов для управления правами.")
                    .foregroundColor(.white)
                    .padding()
            } else {
                List(viewModel.courses) { course in
                    NavigationLink(destination: CourseRightsDetailView(course: course, viewModel: viewModel)) {
                        Text(course.title)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.2)) // Темный фон для каждой строки
                }
            }
        }
        .onAppear {
            viewModel.fetchCourses()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Управление правами")
    }
}
