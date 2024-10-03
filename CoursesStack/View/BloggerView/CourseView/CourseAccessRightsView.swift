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
                    .listRowBackground(Color.gray.opacity(0.2))
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



struct CourseAccessRightsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CourseAccessRightsViewModel()
        // Пример данных для предпросмотра
        viewModel.courses = [
            Course(id: "1", title: "Курс 1", description: "Описание курса 1", price: 29.99, currency: .dollar, coverImageURL: "", authorID: "author1", authorName: "Автор 1", branches: [], reviews: [], completedBranches: [:], purchasedBy: []),
            Course(id: "2", title: "Курс 2", description: "Описание курса 2", price: 19.99, currency: .ruble, coverImageURL: "", authorID: "author2", authorName: "Автор 2", branches: [], reviews: [], completedBranches: [:], purchasedBy: [])
        ]
        
        return NavigationView {
            CourseAccessRightsView()
                .environmentObject(viewModel)
        }
    }
}
