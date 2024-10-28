import SwiftUI

struct CourseAccessRightsView: View {
    @StateObject private var viewModel = CourseAccessRightsViewModel()

    var body: some View {
        VStack {
            if viewModel.courses.isEmpty {
                Text(NSLocalizedString("no_courses_for_management", comment: "")) // Локализованный текст при отсутствии курсов
                    .foregroundColor(.white)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.courses) { course in
                            NavigationLink(destination: CourseRightsDetailView(course: course, viewModel: CourseRightsDetailViewModel(course: course))) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 60/255, green: 60/255, blue: 62/255))
                                        .shadow(radius: 4)
                                    
                                    VStack(alignment: .leading) {
                                        Text(course.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding([.top, .horizontal], 16)
                                        
                                        Text(NSLocalizedString("manage_rights", comment: "")) // Локализованный текст "Управление правами"
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
        .navigationTitle(NSLocalizedString("access_rights_title", comment: "")) // Локализованный заголовок экрана
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    // Действие для кнопки
                }) {
                    Text(NSLocalizedString("add_course_button", comment: "")) // Локализованный текст для кнопки "Добавить курс"
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .cornerRadius(8)
                }
            }
        }
    }
}
