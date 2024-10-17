import FirebaseFirestore
import FirebaseAuth

class UserCoursesViewModel: ObservableObject {
    @Published var purchasedCourses: [Course] = []
    @Published var availableCourses: [Course] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        fetchAllCourses() // Вызов fetchAllCourses
    }
    
    // Загрузка всех курсов и разделение на купленные и доступные
    func fetchAllCourses() {
        isLoading = true
        
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
                print("Данные курса: \(document.data())")  // Диагностика данных
                return self.parseCourseData(data: document.data(), documentID: document.documentID)
            }
            
            // Разделение курсов на купленные и доступные на основе userID
            if let userID = Auth.auth().currentUser?.uid {
                self.purchasedCourses = allCourses.filter { $0.purchasedBy.contains(userID) }
                self.availableCourses = allCourses.filter { !$0.purchasedBy.contains(userID) }
            } else {
                // Если пользователь не авторизован
                self.availableCourses = allCourses
            }
            
            // Диагностика: Вывод количества курсов
            print("Доступные курсы: \(self.availableCourses.count)")
            print("Купленные курсы: \(self.purchasedCourses.count)")
        }
    }
    
    // Функция для разбора данных курса из Firestore
    private func parseCourseData(data: [String: Any], documentID: String) -> Course? {
        let id = documentID  // Используем ID документа напрямую
        let title = data["title"] as? String ?? "Нет названия"
        let description = data["description"] as? String ?? "Описание отсутствует"
        let price = data["price"] as? Double ?? 0.0
        let currency = Currency(rawValue: data["currency"] as? String ?? "USD") ?? .dollar
        let coverImageURL = data["coverImageURL"] as? String ?? ""
        
        let branchesData = data["branches"] as? [[String: Any]] ?? []
        let branches = branchesData.compactMap { CourseBranch.fromDict($0) }
        
        let reviewsData = data["reviews"] as? [[String: Any]] ?? []
        let reviews = reviewsData.compactMap { Review.fromDict($0) }
        
        let completedBranches = data["completedBranches"] as? [String: Bool] ?? [:]
        let purchasedBy = data["purchasedBy"] as? [String] ?? []
        
        return Course(
            id: id,
            title: title,
            description: description,
            price: price,
            currency: currency,
            coverImageURL: coverImageURL,
            authorID: data["authorID"] as? String,
            authorName: data["authorName"] as? String,
            branches: branches,
            reviews: reviews,
            completedBranches: completedBranches,
            purchasedBy: purchasedBy
        )
    }
}
