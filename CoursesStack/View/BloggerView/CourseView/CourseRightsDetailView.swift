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
                    .background(Color.gray.opacity(0.2))
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


struct CourseRightsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CourseAccessRightsViewModel()
        let course = Course(id: "1", title: "Курс 1", description: "Описание курса 1", price: 29.99, currency: .dollar, coverImageURL: "", authorID: "author1", authorName: "Автор 1", branches: [], reviews: [], completedBranches: [:], purchasedBy: [])
        
        // Пример данных для прав доступа
        viewModel.accessRights = [
            CourseAccessRights(courseID: course.id, userID: "user1", canView: true),
            CourseAccessRights(courseID: course.id, userID: "user2", canView: false)
        ]
        
        return NavigationView {
            CourseRightsDetailView(course: course, viewModel: viewModel)
        }
    }
}
