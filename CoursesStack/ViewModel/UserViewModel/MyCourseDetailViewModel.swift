import Foundation
import FirebaseFirestore

class MyCourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var errorMessage: AlertMessage?
    private let db = Firestore.firestore()
    
    init(course: Course) {
        self.course = course
        fetchCourseDetails()
    }
    
    // Загрузка данных курса из Firestore
    func fetchCourseDetails() {
        let courseRef = db.collection("courses").document(course.id)
        
        courseRef.getDocument { [weak self] (document, error) in
            if let error = error {
                self?.errorMessage = AlertMessage(message: "Ошибка при загрузке данных курса: \(error.localizedDescription)")
                return
            }
            
            if let document = document, let data = document.data() {
                // Печатаем загруженные данные
                print("Загруженные данные курса: \(data)")
                
                if let parsedCourse = self?.parseCourseData(data: data, documentID: document.documentID) {
                    self?.course = parsedCourse
                    // Печатаем количество веток
                    print("Количество веток: \(self?.course.branches.count ?? 0)")
                } else {
                    self?.errorMessage = AlertMessage(message: "Не удалось извлечь данные курса.")
                }
            } else {
                self?.errorMessage = AlertMessage(message: "Курс не найден.")
            }
        }
    }
    
    // Функция для разбора данных курса
    private func parseCourseData(data: [String: Any], documentID: String) -> Course {
        let title = data["title"] as? String ?? "Нет названия"
        let description = data["description"] as? String ?? "Описание не найдено"
        let price = data["price"] as? Double ?? 0.0
        let currency = Currency(rawValue: data["currency"] as? String ?? "USD") ?? .dollar
        let coverImageURL = data["coverImageURL"] as? String ?? ""
        
        // Разбор веток курса
        let branchesData = data["branches"] as? [[String: Any]] ?? []
        let branches = branchesData.compactMap { dict -> CourseBranch? in
            guard let id = dict["id"] as? String,
                  let title = dict["title"] as? String,
                  let description = dict["description"] as? String else {
                return nil
            }
            
            // Разбор уроков в ветке
            let lessonsData = dict["lessons"] as? [[String: Any]] ?? []
            let lessons = lessonsData.compactMap { lessonDict -> Lesson? in
                guard let id = lessonDict["id"] as? String,
                      let title = lessonDict["title"] as? String,
                      let content = lessonDict["content"] as? String else {
                    return nil
                }
                let videoURL = lessonDict["videoURL"] as? String
                return Lesson(id: id, title: title, content: content, videoURL: videoURL, assignments: [], downloadableFiles: [])
            }
            
            return CourseBranch(id: id, title: title, description: description, lessons: lessons)
        }
        
        let reviewsData = data["reviews"] as? [[String: Any]] ?? []
        let reviews = reviewsData.compactMap { Review.fromDict($0) }
        let completedBranches = data["completedBranches"] as? [String: Bool] ?? [:]
        let purchasedBy = data["purchasedBy"] as? [String] ?? []
        
        return Course(
            id: documentID,
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
