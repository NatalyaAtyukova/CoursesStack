import SwiftUI

struct CourseRightsDetailView: View {
    var course: Course
    @ObservedObject var viewModel: CourseAccessRightsViewModel

    var body: some View {
        VStack {
            if viewModel.accessRights.isEmpty {
                Text("Нет пользователей с правами доступа.")
                    .foregroundColor(.white)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.accessRights) { rights in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Пользователь: \(rights.userID)")
                                        .foregroundColor(.white)
                                        .font(.headline)

                                    Text("ID курса: \(rights.courseID)")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }

                                Spacer()

                                Toggle(isOn: Binding<Bool>(
                                    get: { rights.canView },
                                    set: { newValue in
                                        viewModel.updateAccessRights(courseID: rights.courseID, userID: rights.userID, canView: newValue)
                                    }
                                )) {
                                    Text("Может просматривать")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(Color(red: 60/255, green: 60/255, blue: 62/255)) // Фон карточки
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            ) // Легкая окантовка
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5) // Тень для карточки
                        }
                    }
                    .padding(.horizontal, 16) // Отступы по бокам
                }
            }
        }
        .onAppear {
            viewModel.fetchAccessRights(for: course)
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all)) // Темный фон
        .navigationTitle("Права для \(course.title)")
    }
}
