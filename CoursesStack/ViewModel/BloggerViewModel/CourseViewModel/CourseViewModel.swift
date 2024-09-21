import FirebaseFirestore
import FirebaseAuth

class CourseViewModel: ObservableObject {
    @Published var course: Course
    @Published var errorMessage: AlertMessage?
    private let db = Firestore.firestore()

    init(course: Course) {
        self.course = course
    }
    
    // Добавление новой ветки
    func addBranch(title: String, description: String) {
        let newBranch = CourseBranch(id: UUID().uuidString, title: title, description: description, lessons: [])
        course.branches.append(newBranch)
        saveCourse()
    }
    
    // Добавление нового урока в ветку
    func addLesson(toBranch branchID: String, title: String, content: String, videoURL: String? = nil, assignments: [Assignment] = [], downloadableFiles: [DownloadableFile] = []) {
        if let index = course.branches.firstIndex(where: { $0.id == branchID }) {
            let newLesson = Lesson(
                id: UUID().uuidString,
                title: title,
                content: content,
                videoURL: videoURL,
                assignments: assignments, // Массив объектов Assignment
                downloadableFiles: downloadableFiles // Массив объектов DownloadableFile
            )
            course.branches[index].lessons.append(newLesson)
            saveCourse()
        } else {
            self.errorMessage = AlertMessage(message: "Ветка курса не найдена")
        }
    }
    
    // Добавление отзыва
    func addReview(content: String, rating: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = AlertMessage(message: "Необходимо авторизоваться")
            return
        }
        let newReview = Review(id: UUID().uuidString, userID: userID, content: content, rating: rating)
        course.reviews.append(newReview)
        saveCourse()
    }

    // Сохранение курса в Firestore
    func saveCourse() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = AlertMessage(message: "Необходимо авторизоваться")
            return
        }
        
        let courseData: [String: Any] = [
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "price": course.price,
            "coverImageURL": course.coverImageURL,
            "authorID": course.authorID,
            "branches": course.branches.map { $0.toDict() },
            "reviews": course.reviews.map { $0.toDict() }
        ]
        
        db.collection("courses").document(course.id).setData(courseData) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка сохранения курса: \(error.localizedDescription)")
            }
        }
    }
}

// Extension для CourseBranch
extension CourseBranch {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "lessons": lessons.map { $0.toDict() } // Преобразование уроков в словарь
        ]
    }
}

// Extension для Lesson
extension Lesson {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "content": content,
            "videoURL": videoURL ?? "", // Сохранение URL видео, если есть
            "assignments": assignments, // Преобразование заданий в массив строк
            "downloadableFiles": downloadableFiles // Файлы для скачивания
        ]
    }
}

// Extension для Review
extension Review {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "userID": userID,
            "content": content,
            "rating": rating
        ]
    }
}
