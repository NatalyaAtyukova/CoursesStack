import Foundation
import FirebaseFirestore
import FirebaseAuth

class MyCourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var reviews: [Review] = []  // Хранение отзывов отдельно
    @Published var errorMessage: AlertMessage?
    private let db = Firestore.firestore()

    init(course: Course) {
        self.course = course
        fetchCourseDetails()
        fetchReviews()  // Загружаем отзывы отдельно при инициализации
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
                if let parsedCourse = self?.parseCourseData(data: data, documentID: document.documentID) {
                    self?.course = parsedCourse
                } else {
                    self?.errorMessage = AlertMessage(message: "Не удалось извлечь данные курса.")
                }
            } else {
                self?.errorMessage = AlertMessage(message: "Курс не найден.")
            }
        }
    }

    // Загрузка отзывов для курса
    func fetchReviews() {
        db.collection("reviews").whereField("courseID", isEqualTo: course.id).getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = AlertMessage(message: "Ошибка при загрузке отзывов: \(error.localizedDescription)")
                return
            }
            
            self?.reviews = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Review.self)
            } ?? []
        }
    }

    // Функция для добавления отзыва
    func addReview(content: String, rating: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = AlertMessage(message: "Ошибка: пользователь не авторизован.")
            return
        }
        
        let review = Review(id: UUID().uuidString, courseID: course.id, userID: userID, content: content, rating: rating)
        let reviewRef = db.collection("reviews").document(review.id)
        
        do {
            try reviewRef.setData(from: review) { [weak self] error in
                if let error = error {
                    self?.errorMessage = AlertMessage(message: "Ошибка при добавлении отзыва: \(error.localizedDescription)")
                } else {
                    print("Отзыв успешно добавлен")
                    self?.fetchReviews()  // Обновляем список отзывов
                }
            }
        } catch {
            self.errorMessage = AlertMessage(message: "Ошибка при сериализации отзыва.")
        }
    }

    // Функция для редактирования отзыва
    func updateReview(review: Review, newContent: String, newRating: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = AlertMessage(message: "Ошибка: пользователь не авторизован.")
            return
        }
        
        guard review.userID == userID else {
            self.errorMessage = AlertMessage(message: "Ошибка: вы не можете редактировать этот отзыв.")
            return
        }
        
        let updatedReview = Review(id: review.id, courseID: review.courseID, userID: review.userID, content: newContent, rating: newRating)
        let reviewRef = db.collection("reviews").document(review.id)
        
        do {
            try reviewRef.setData(from: updatedReview) { [weak self] error in
                if let error = error {
                    self?.errorMessage = AlertMessage(message: "Ошибка при обновлении отзыва: \(error.localizedDescription)")
                } else {
                    print("Отзыв успешно обновлён")
                    self?.fetchReviews()  // Обновляем список отзывов
                }
            }
        } catch {
            self.errorMessage = AlertMessage(message: "Ошибка при сериализации отзыва.")
        }
    }

    // Функция для удаления отзыва
    func deleteReview(review: Review) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = AlertMessage(message: "Ошибка: пользователь не авторизован.")
            return
        }
        
        guard review.userID == userID else {
            self.errorMessage = AlertMessage(message: "Ошибка: вы не можете удалить этот отзыв.")
            return
        }

        let reviewRef = db.collection("reviews").document(review.id)
        
        reviewRef.delete { [weak self] error in
            if let error = error {
                self?.errorMessage = AlertMessage(message: "Ошибка при удалении отзыва: \(error.localizedDescription)")
            } else {
                print("Отзыв успешно удалён")
                self?.fetchReviews()  // Обновляем список отзывов
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
        let branchesData = data["branches"] as? [[String: Any]] ?? []
        let branches = branchesData.compactMap { dict -> CourseBranch? in
            guard let id = dict["id"] as? String,
                  let title = dict["title"] as? String,
                  let description = dict["description"] as? String else {
                return nil
            }
            let lessonsData = dict["lessons"] as? [[String: Any]] ?? []
            let lessons = lessonsData.compactMap { lessonDict -> Lesson? in
                guard let id = lessonDict["id"] as? String,
                      let title = lessonDict["title"] as? String,
                      let content = lessonDict["content"] as? String else {
                    return nil
                }
                let videoURL = lessonDict["videoURL"] as? String
                let assignmentsData = lessonDict["assignments"] as? [[String: Any]] ?? []
                let assignments = assignmentsData.compactMap { assignmentDict -> Assignment? in
                    guard let id = assignmentDict["id"] as? String,
                          let title = assignmentDict["title"] as? String,
                          let typeRawValue = assignmentDict["type"] as? String,
                          let type = AssignmentType(rawValue: typeRawValue),
                          let correctAnswer = assignmentDict["correctAnswer"] as? String else {
                        return nil
                    }
                    let choices = assignmentDict["choices"] as? [String] ?? []
                    return Assignment(id: id, title: title, type: type, choices: choices, correctAnswer: correctAnswer)
                }
                return Lesson(id: id, title: title, content: content, videoURL: videoURL, assignments: assignments, downloadableFiles: [])
            }
            return CourseBranch(id: id, title: title, description: description, lessons: lessons)
        }

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
            completedBranches: completedBranches,
            purchasedBy: purchasedBy
        )
    }
}
