import SwiftUI

struct UserCoursesView: View {
    @StateObject private var viewModel = UserCoursesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка курсов...")
                } else {
                    List {
                        // Раздел для купленных курсов
                        Section(header: Text("Купленные курсы")) {
                            if viewModel.purchasedCourses.isEmpty {
                                Text("Вы еще не купили ни одного курса.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.purchasedCourses) { course in
                                    // Отображение купленных курсов
                                    NavigationLink(destination: MyCourseDetailView(viewModel: MyCourseDetailViewModel(course: course))) {
                                        CourseRow(course: course)
                                    }
                                }
                            }
                        }

                        // Раздел для доступных курсов
                        Section(header: Text("Доступные курсы")) {
                            if viewModel.availableCourses.isEmpty {
                                Text("Нет доступных курсов для покупки.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.availableCourses) { course in
                                    // Отображение доступных курсов с возможностью покупки
                                    NavigationLink(destination: CoursePurchaseView(viewModel: CoursePurchaseViewModel(course: course))) {
                                        CourseRow(course: course)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Мои курсы")
        }
    }
}
