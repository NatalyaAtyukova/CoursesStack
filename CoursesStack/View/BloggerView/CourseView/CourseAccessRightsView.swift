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
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.courses) { course in
                            NavigationLink(destination: CourseRightsDetailView(course: course, viewModel: viewModel)) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 60/255, green: 60/255, blue: 62/255))
                                        .shadow(radius: 4)
                                    
                                    VStack(alignment: .leading) {
                                        Text(course.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding([.top, .horizontal], 16)
                                        
                                        Text("Управление правами")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding([.horizontal, .bottom], 16)
                                    }
                                }
                                .frame(height: 100)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.fetchCourses()
        }
        .navigationTitle("Управление правами")
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // Действие для кнопки
                }) {
                    Text("Добавить курс")
                        .foregroundColor(.white) // Белый цвет текста кнопки
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                        .cornerRadius(8)
                }
            }
        }
    }
}
