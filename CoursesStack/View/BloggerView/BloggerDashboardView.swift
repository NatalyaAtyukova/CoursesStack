import SwiftUI

struct BloggerDashboardView: View {
    @StateObject private var viewModel = BloggerDashboardViewModel()
    @State private var showingCreateCourse = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.courses.isEmpty {
                    Text("У вас пока нет курсов. Создайте первый курс.")
                        .padding()
                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(destination: CourseDetailView(viewModel: CourseDetailViewModel(course: course))) {
                            CourseRow(course: course)
                        }
                    }
                }
                Spacer()
                Button(action: {
                    showingCreateCourse.toggle()
                }) {
                    Text("Создать новый курс")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showingCreateCourse) {
                    CreateCourseView(viewModel: viewModel)
                }
            }
            .navigationTitle("Ваши курсы")
            .onAppear {
                viewModel.fetchCourses()
            }
            .errorAlert($viewModel.errorMessage) // Используем модификатор для отображения ошибок
        }
    }
}
