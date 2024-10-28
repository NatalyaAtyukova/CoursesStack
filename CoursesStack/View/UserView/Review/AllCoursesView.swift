import SwiftUI

struct AllCoursesView: View {
    @StateObject private var viewModel = UserCoursesViewModel() // Используем тот же ViewModel для курса

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 44/255, green: 44/255, blue: 46/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView(NSLocalizedString("loading_message", comment: "")) // Локализованное сообщение "Загрузка..."
                            .foregroundColor(.white)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                if !viewModel.availableCourses.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(NSLocalizedString("available_courses_title", comment: "")) // Локализованный заголовок "Доступные курсы"
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
                                    Text(NSLocalizedString("no_courses_available", comment: "")) // Локализованный текст "Нет доступных курсов для покупки."
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                        .padding(.top, 20)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(NSLocalizedString("all_courses_navigation_title", comment: "")) // Локализованный заголовок "Все курсы"
                .foregroundColor(.white)
            }
            .onAppear {
                viewModel.fetchAllCourses()
            }
        }
    }
}
