import SwiftUI

struct UserCoursesView: View {
    @StateObject private var viewModel = UserCoursesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Темный фон для всего экрана
                Color(red: 44/255, green: 44/255, blue: 46/255)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if viewModel.isLoading {
                        ProgressView("Загрузка курсов...")
                            .foregroundColor(.white)
                    } else if let error = viewModel.errorMessage {
                        // Отображение ошибки
                        Text(error)
                            .foregroundColor(.red)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Раздел для купленных курсов
                                if !viewModel.purchasedCourses.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Купленные курсы")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .padding(.leading, 16)

                                        ForEach(viewModel.purchasedCourses) { course in
                                            NavigationLink(destination: MyCourseDetailView(viewModel: MyCourseDetailViewModel(course: course))) {
                                                CourseRow(course: course)
                                                    .padding()
                                                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                                                    .cornerRadius(12)
                                                    .shadow(radius: 5)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                } else {
                                    Text("Вы еще не купили ни одного курса.")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                        .padding(.top, 20)
                                }

                                // Раздел для доступных курсов
                                if !viewModel.availableCourses.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Доступные курсы")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .padding(.leading, 16)

                                        ForEach(viewModel.availableCourses) { course in
                                            NavigationLink(destination: CoursePurchaseView(viewModel: CoursePurchaseViewModel(course: course))) {
                                                CourseRow(course: course)
                                                    .padding()
                                                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                                                    .cornerRadius(12)
                                                    .shadow(radius: 5)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                } else {
                                    Text("Нет доступных курсов для покупки.")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                        .padding(.top, 20)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Мои курсы")
                .foregroundColor(.white)
            }
            // Вызов метода загрузки курсов при появлении экрана
            .onAppear {
                viewModel.fetchAllCourses() // Вызов метода
            }
        }
    }
}
