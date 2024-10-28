import SwiftUI

struct BloggerDashboardView: View {
    @StateObject private var viewModel = BloggerDashboardViewModel()
    @State private var showingCreateCourse = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                Color(red: 44/255, green: 44/255, blue: 46/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.courses.isEmpty {
                        // Сообщение, если нет курсов
                        Text(NSLocalizedString("no_courses_message", comment: "")) // Локализованное сообщение "У вас пока нет курсов"
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    } else {
                        // Убираем белый фон у списка
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(viewModel.courses) { course in
                                    NavigationLink(destination: CourseDetailView(viewModel: CourseDetailViewModel(course: course))) {
                                        CourseRow(course: course)
                                            .padding()
                                            .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                                            .cornerRadius(12)
                                            .shadow(radius: 5)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Кнопка создания курса
                    Button(action: {
                        showingCreateCourse.toggle()
                    }) {
                        Text(NSLocalizedString("create_course_button", comment: "")) // Локализованная кнопка "Создать курс"
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(radius: 5)
                    }
                    .sheet(isPresented: $showingCreateCourse) {
                        CreateCourseView(viewModel: viewModel)
                    }
                    .padding(.bottom, 40)
                }
            }
            // Убираем заголовок навигации
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchCourses()
            }
            .errorAlert($viewModel.errorMessage)
        }
    }
}
