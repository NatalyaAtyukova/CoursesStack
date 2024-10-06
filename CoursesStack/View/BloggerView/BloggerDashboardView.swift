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
                        Text("У вас пока нет курсов")
                            .font(.headline)
                            .foregroundColor(.white) // Белый текст
                            .padding(.top, 20) // Более плотный отступ
                    } else {
                        // Убираем белый фон у списка
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(viewModel.courses) { course in
                                    NavigationLink(destination: CourseDetailView(viewModel: CourseDetailViewModel(course: course))) {
                                        CourseRow(course: course)
                                            .padding()
                                            .background(Color(red: 60/255, green: 60/255, blue: 62/255)) // Темный фон для строк списка
                                            .cornerRadius(12)
                                            .shadow(radius: 5) // Легкая тень для визуальной глубины
                                        
                                    }
                                    .padding(.horizontal, 16) // Пространство по краям
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Кнопка создания курса
                    Button(action: {
                        showingCreateCourse.toggle()
                    }) {
                        Text("Создать курс")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
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
            .navigationBarHidden(true) // Скрыть заголовок
            .onAppear {
                viewModel.fetchCourses()
            }
            .errorAlert($viewModel.errorMessage)
        }
    }
}
