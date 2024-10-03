import Firebase
import FirebaseAuth

class CourseAccessRightsViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course?
    @Published var accessRights: [CourseAccessRights] = []
    @Published var errorMessage: String?

    // Получаем список курсов, которые принадлежат автору
    func fetchCourses() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? ""

        db.collection("courses")
            .whereField("authorID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                self.courses = snapshot?.documents.compactMap { document in
                    try? document.data(as: Course.self)
                } ?? []
            }
    }

    // Получаем права доступа для выбранного курса
    func fetchAccessRights(for course: Course) {
        let db = Firestore.firestore()

        db.collection("courses").document(course.id).collection("accessRights")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                self.accessRights = snapshot?.documents.compactMap { document in
                    try? document.data(as: CourseAccessRights.self)
                } ?? []
            }
    }

    // Обновляем права доступа пользователя (только просмотр)
    func updateAccessRights(courseID: String, userID: String, canView: Bool) {
        let db = Firestore.firestore()

        let accessRightsRef = db.collection("courses").document(courseID).collection("accessRights").document(userID)

        accessRightsRef.setData([
            "courseID": courseID,
            "userID": userID,
            "canView": canView
        ]) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
