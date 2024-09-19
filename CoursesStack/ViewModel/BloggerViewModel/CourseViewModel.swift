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
    
    // Добавление урока в ветку
    func addLesson(toBranch branchID: String, title: String, content: String) {
        if let index = course.branches.firstIndex(where: { $0.id == branchID }) {
            let newLesson = Lesson(id: UUID().uuidString, title: title, content: content)
            course.branches[index].lessons.append(newLesson)
            saveCourse()
        }
    }

    // Добавление теста
    func addQuiz(title: String) {
        let newQuiz = Quiz(id: UUID().uuidString, title: title, questions: [])
        course.quizzes.append(newQuiz)
        saveCourse()
    }

    // Сохранение курса в Firestore
    func saveCourse() {  // Убираем модификатор private
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let courseData = [
            "title": course.title,
            "description": course.description,
            "price": course.price,
            "coverImageURL": course.coverImageURL,
            "authorID": course.authorID,
            "branches": course.branches.map { $0.toDict() }, // Преобразуем в словарь для сохранения
            "quizzes": course.quizzes.map { $0.toDict() }
        ] as [String : Any]
        
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
            "content": content
        ]
    }
}

// Extension для Quiz
extension Quiz {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "questions": questions.map { $0.toDict() }
        ]
    }
}

// Extension для Question
extension Question {
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "questionText": questionText,
            "answers": answers,
            "correctAnswerIndex": correctAnswerIndex
        ]
    }
}
