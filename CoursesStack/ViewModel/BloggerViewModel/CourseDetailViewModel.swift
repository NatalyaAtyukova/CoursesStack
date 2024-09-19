import Foundation
import FirebaseFirestore

class CourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var errorMessage: AlertMessage? // Используем AlertMessage для корректной работы с alert
    @Published var isDeleted = false
    private let db = Firestore.firestore()
    
    init(course: Course) {
        self.course = course
    }
    
    // Добавление ветки в курс
    func addBranch(title: String, description: String) {
        let newBranch = CourseBranch(id: UUID().uuidString, title: title, description: description, lessons: [])
        course.branches.append(newBranch)
        saveCourse() // Сохраняем курс с добавленной веткой
    }
    
    // Сохранение изменений курса в Firestore
    func saveCourse() {
        guard !course.id.isEmpty else { return }
        
        let courseData = [
            "title": course.title,
            "description": course.description,
            "price": course.price,
            "branches": course.branches.map { $0.toDict() }, // Преобразуем ветки в словарь
            "quizzes": course.quizzes.map { $0.toDict() } // Преобразуем тесты в словарь
        ] as [String : Any]
        
        db.collection("courses").document(course.id).setData(courseData) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка сохранения курса: \(error.localizedDescription)")
            }
        }
    }
    
    // Обновление курса
    func updateCourse(title: String, description: String, price: Double) {
        guard !course.id.isEmpty else { return }
        
        db.collection("courses").document(course.id).updateData([
            "title": title,
            "description": description,
            "price": price
        ]) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка обновления курса: \(error.localizedDescription)")
            } else {
                self.course.title = title
                self.course.description = description
                self.course.price = price
            }
        }
    }
    
    // Удаление курса
    func deleteCourse() {
        db.collection("courses").document(course.id).delete { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка удаления курса: \(error.localizedDescription)")
            } else {
                self.isDeleted = true
            }
        }
    }
}


