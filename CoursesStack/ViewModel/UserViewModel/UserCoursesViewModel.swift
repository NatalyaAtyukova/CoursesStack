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
    
    // Загрузка всех курсов и фильтрация на клиенте
    func fetchUserCourses() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться"
            return
        }
        
        isLoading = true
        
        // Загрузка всех курсов
        db.collection("courses").getDocuments { (snapshot, error) in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Ошибка загрузки курсов: \(error.localizedDescription)"
                return
            }
            
            guard let snapshot = snapshot else {
                self.errorMessage = "Нет данных для загрузки курсов"
                return
            }
            
            let allCourses = snapshot.documents.compactMap { document -> Course? in
                print("Данные курса: \(document.data())")  // Вывод данных для диагностики
                
                return self.parseCourseData(data: document.data())
            }
            
            // Вывод количества загруженных курсов для диагностики
            print("Загруженные курсы: \(allCourses.count)")
            
            // Фильтрация курсов
            self.purchasedCourses = allCourses.filter { $0.purchasedBy.contains(userID) }
            self.availableCourses = allCourses.filter { !$0.purchasedBy.contains(userID) }
            
            // Вывод данных для диагностики
            print("Купленные курсы: \(self.purchasedCourses.count)")
            print("Доступные курсы: \(self.availableCourses.count)")
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
            let completedBranches = data["completedBranches"] as? [String: Bool],
            let purchasedBy = data["purchasedBy"] as? [String]  // Это важно для фильтрации
        else {
            print("Не удалось разобрать данные курса: \(data)")  // Отладочный вывод
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
                    assignments: [],
                    downloadableFiles: []
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
            authorID: data["authorID"] as? String,  // Опционально
            authorName: data["authorName"] as? String,  // Опционально
            branches: branches,
            reviews: reviews,
            completedBranches: completedBranches,
            purchasedBy: purchasedBy  // Для фильтрации курсов
        )
    }
}
