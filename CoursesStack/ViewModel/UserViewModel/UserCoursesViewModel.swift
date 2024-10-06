import FirebaseFirestore
import FirebaseAuth

class UserCoursesViewModel: ObservableObject {
    @Published var purchasedCourses: [Course] = []
    @Published var availableCourses: [Course] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        fetchUserCourses()
    }

    // Загрузка курсов пользователя
    func fetchUserCourses() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться"
            return
        }

        isLoading = true

        // Загрузка купленных курсов
        db.collection("courses")
            .whereField("purchasedBy", arrayContains: userID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    self.errorMessage = "Ошибка получения купленных курсов: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                if let snapshot = snapshot {
                    self.purchasedCourses = snapshot.documents.compactMap { document in
                        self.parseCourseData(data: document.data())
                    }
                }

                // Загрузка доступных курсов после получения купленных курсов
                self.fetchAvailableCourses(userID: userID)
            }
    }

    // Загрузка доступных курсов
    private func fetchAvailableCourses(userID: String) {
        db.collection("courses")
            .whereField("purchasedBy", notIn: [userID]) // Курсы, которые не куплены текущим пользователем
            .getDocuments { (snapshot, error) in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Ошибка получения доступных курсов: \(error.localizedDescription)"
                    return
                }

                if let snapshot = snapshot {
                    self.availableCourses = snapshot.documents.compactMap { document in
                        self.parseCourseData(data: document.data())
                    }
                }
            }
    }

    // Функция для разбора данных курса из Firestore
    private func parseCourseData(data: [String: Any]) -> Course? {
        guard
            let id = data["id"] as? String,
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let price = data["price"] as? Double,
            let currencyString = data["currency"] as? String,
            let currency = Currency(rawValue: currencyString),
            let coverImageURL = data["coverImageURL"] as? String,
            let authorID = data["authorID"] as? String,
            let authorName = data["authorName"] as? String,
            let completedBranches = data["completedBranches"] as? [String: Bool],
            let purchasedBy = data["purchasedBy"] as? [String]
        else {
            return nil
        }

        let branchesData = data["branches"] as? [[String: Any]] ?? []
        let branches = branchesData.map { dict -> CourseBranch in
            let lessonsData = dict["lessons"] as? [[String: Any]] ?? []
            let lessons = lessonsData.map { lessonDict -> Lesson in
                return Lesson(
                    id: lessonDict["id"] as? String ?? UUID().uuidString,
                    title: lessonDict["title"] as? String ?? "",
                    content: lessonDict["content"] as? String ?? "",
                    videoURL: lessonDict["videoURL"] as? String,
                    assignments: [],  // Если нужно, добавьте задания
                    downloadableFiles: []  // Если нужно, добавьте файлы для скачивания
                )
            }
            return CourseBranch(
                id: dict["id"] as? String ?? UUID().uuidString,
                title: dict["title"] as? String ?? "",
                description: dict["description"] as? String ?? "",
                lessons: lessons
            )
        }

        let reviewsData = data["reviews"] as? [[String: Any]] ?? []
        let reviews = reviewsData.map { reviewDict -> Review in
            return Review(
                id: reviewDict["id"] as? String ?? UUID().uuidString,
                userID: reviewDict["userID"] as? String ?? "",
                content: reviewDict["content"] as? String ?? "",
                rating: reviewDict["rating"] as? Int ?? 0
            )
        }

        return Course(
            id: id,
            title: title,
            description: description,
            price: price,
            currency: currency,
            coverImageURL: coverImageURL,
            authorID: authorID,
            authorName: authorName,
            branches: branches,
            reviews: reviews,
            completedBranches: completedBranches,
            purchasedBy: purchasedBy
        )
    }
}
