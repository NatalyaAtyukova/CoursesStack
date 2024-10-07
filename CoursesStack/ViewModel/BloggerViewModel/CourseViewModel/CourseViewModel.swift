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
            "authorName": course.authorName,
            "branches": course.branches.map { $0.toDict() }, // Преобразование веток в массив словарей
            "reviews": course.reviews.map { $0.toDict() } // Преобразование отзывов в массив словарей
        ]
        
        // Сохранение данных в Firestore
        db.collection("courses").document(course.id).setData(courseData) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка сохранения курса: \(error.localizedDescription)")
            } else {
                print("Курс успешно сохранен!")
            }
        }
    }
}

// Расширение для CourseBranch с методом toDict
extension CourseBranch {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "lessons": lessons.map { $0.toDict() }
        ]
    }
    
    static func fromDict(_ dict: [String: Any]) -> CourseBranch? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let description = dict["description"] as? String,
              let lessonsData = dict["lessons"] as? [[String: Any]] else { return nil }
        
        let lessons = lessonsData.compactMap { Lesson.fromDict($0) }
        return CourseBranch(id: id, title: title, description: description, lessons: lessons)
    }
}

// Расширение для Lesson с методом toDict
extension Lesson {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "content": content,
            "videoURL": videoURL ?? "",
            "assignments": assignments.map { $0.toDict() },
            "downloadableFiles": downloadableFiles.map { $0.toDict() }
        ]
    }
    
    static func fromDict(_ dict: [String: Any]) -> Lesson? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let content = dict["content"] as? String else { return nil }
        
        let videoURL = dict["videoURL"] as? String
        let assignmentsData = dict["assignments"] as? [[String: Any]] ?? []
        let assignments = assignmentsData.compactMap { Assignment.fromDict($0) }
        let filesData = dict["downloadableFiles"] as? [[String: Any]] ?? []
        let downloadableFiles = filesData.compactMap { DownloadableFile.fromDict($0) }
        
        return Lesson(id: id, title: title, content: content, videoURL: videoURL, assignments: assignments, downloadableFiles: downloadableFiles)
    }
}

// Расширение для Review с методом toDict
extension Review {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "userID": userID,
            "content": content,
            "rating": rating
        ]
    }
    
    static func fromDict(_ dict: [String: Any]) -> Review? {
        guard let id = dict["id"] as? String,
              let userID = dict["userID"] as? String,
              let content = dict["content"] as? String,
              let rating = dict["rating"] as? Int else { return nil }
        
        return Review(id: id, userID: userID, content: content, rating: rating)
    }
}

// Расширение для Assignment с методом toDict
extension Assignment {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "type": type.rawValue,
            "choices": choices,
            "correctAnswer": correctAnswer
        ]
    }
    
    static func fromDict(_ dict: [String: Any]) -> Assignment? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let typeString = dict["type"] as? String,
              let type = AssignmentType(rawValue: typeString),
              let choices = dict["choices"] as? [String],
              let correctAnswer = dict["correctAnswer"] as? String else { return nil }
        
        return Assignment(id: id, title: title, type: type, choices: choices, correctAnswer: correctAnswer)
    }
}

// Расширение для DownloadableFile с методом toDict
extension DownloadableFile {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "fileName": fileName,
            "fileURL": fileURL
        ]
    }
    
    static func fromDict(_ dict: [String: Any]) -> DownloadableFile? {
        guard let id = dict["id"] as? String,
              let fileName = dict["fileName"] as? String,
              let fileURL = dict["fileURL"] as? String else { return nil }
        
        return DownloadableFile(id: id, fileName: fileName, fileURL: fileURL)
    }
}
