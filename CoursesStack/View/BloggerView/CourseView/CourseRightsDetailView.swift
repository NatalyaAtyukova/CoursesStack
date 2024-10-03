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
                List(viewModel.accessRights) { rights in
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
                    .background(Color.gray.opacity(0.2)) // Темный фон для каждого элемента списка
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            viewModel.fetchAccessRights(for: course)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Права для \(course.title)")
    }
}
