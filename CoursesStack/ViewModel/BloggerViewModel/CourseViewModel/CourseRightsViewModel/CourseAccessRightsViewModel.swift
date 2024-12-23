import FirebaseFirestore
import FirebaseAuth

class CourseAccessRightsViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course?
    @Published var accessRights: [CourseAccessRights] = []
    @Published var reviews: [Review] = []
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
                    print("Ошибка загрузки курсов: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot {
                    self.courses = snapshot.documents.compactMap { document in
                        let data = document.data()
                        let branchesData = data["branches"] as? [[String: Any]] ?? []
                        let branches: [CourseBranch] = branchesData.compactMap { branchData in
                            let lessonsData = branchData["lessons"] as? [[String: Any]] ?? []
                            let lessons: [Lesson] = lessonsData.compactMap { lessonData in
                                let assignmentsData = lessonData["assignments"] as? [[String: Any]] ?? []
                                let assignments: [Assignment] = assignmentsData.compactMap { assignmentData in
                                    return Assignment(
                                        id: assignmentData["id"] as? String ?? UUID().uuidString,
                                        title: assignmentData["title"] as? String ?? "",
                                        type: AssignmentType(rawValue: assignmentData["type"] as? String ?? "") ?? .multipleChoice,
                                        choices: assignmentData["choices"] as? [String] ?? [],
                                        correctAnswer: assignmentData["correctAnswer"] as? String ?? ""
                                    )
                                }

                                let downloadableFilesData = lessonData["downloadableFiles"] as? [[String: Any]] ?? []
                                let downloadableFiles: [DownloadableFile] = downloadableFilesData.compactMap { fileData in
                                    return DownloadableFile(
                                        id: fileData["id"] as? String ?? UUID().uuidString,
                                        fileName: fileData["fileName"] as? String ?? "",
                                        fileURL: fileData["fileURL"] as? String ?? ""
                                    )
                                }

                                return Lesson(
                                    id: lessonData["id"] as? String ?? UUID().uuidString,
                                    title: lessonData["title"] as? String ?? "",
                                    content: lessonData["content"] as? String ?? "",
                                    videoURL: lessonData["videoURL"] as? String,
                                    assignments: assignments,
                                    downloadableFiles: downloadableFiles
                                )
                            }

                            return CourseBranch(
                                id: branchData["id"] as? String ?? UUID().uuidString,
                                title: branchData["title"] as? String ?? "",
                                description: branchData["description"] as? String ?? "",
                                lessons: lessons
                            )
                        }

                        let completedBranches = data["completedBranches"] as? [String: Bool] ?? [:]
                        let purchasedBy = data["purchasedBy"] as? [String] ?? []

                        return Course(
                            id: document.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0.0,
                            currency: Currency(rawValue: data["currency"] as? String ?? "") ?? .dollar,
                            coverImageURL: data["coverImageURL"] as? String ?? "",
                            authorID: data["authorID"] as? String ?? "",
                            authorName: data["authorName"] as? String ?? "",
                            branches: branches,
                            completedBranches: completedBranches,
                            purchasedBy: purchasedBy
                        )
                    }
                }

                if self.courses.isEmpty {
                    print("Нет курсов для отображения")
                    self.errorMessage = "Нет доступных курсов."
                }
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

    // Получаем отзывы для выбранного курса
    func fetchReviews(for course: Course) {
        let db = Firestore.firestore()

        db.collection("courses").document(course.id).collection("reviews")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                self.reviews = snapshot?.documents.compactMap { document in
                    try? document.data(as: Review.self)
                } ?? []
            }
    }

    // Обновляем права доступа пользователя
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
