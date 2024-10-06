import Foundation
import FirebaseFirestore

class CourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var errorMessage: AlertMessage? // Для корректной работы с alert
    @Published var isDeleted = false
    @Published var activeLesson: Lesson? // Активный урок для отображения или обработки
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
    
    // Добавление урока в ветку с новыми параметрами
    func addLesson(to branchID: String, title: String, content: String, videoURL: String?, assignments: [Assignment], downloadableFiles: [DownloadableFile]) {
        if let branchIndex = course.branches.firstIndex(where: { $0.id == branchID }) {
            let newLesson = Lesson(
                id: UUID().uuidString,
                title: title,
                content: content,
                videoURL: videoURL, // Передаем videoURL, если оно есть
                assignments: assignments, // Передаем список заданий
                downloadableFiles: downloadableFiles // Передаем файлы для скачивания
            )
            course.branches[branchIndex].lessons.append(newLesson)
            saveCourse() // Сохраняем курс с добавленным уроком
        }
    }
    
    // Открытие урока
    func openLesson(_ lesson: Lesson) {
        activeLesson = lesson
        // Логика для отображения или обработки выбранного урока
    }

    // Сохранение изменений курса в Firestore
    func saveCourse() {
        guard !course.id.isEmpty else { return }

        let courseData: [String: Any] = [
            "title": course.title,
            "description": course.description,
            "price": course.price,
            "currency": course.currency.rawValue, // Сохраняем строковое значение валюты
            "coverImageURL": course.coverImageURL, // Сохраняем URL обложки курса
            "authorID": course.authorID,
            "authorName": course.authorName,
            "branches": course.branches.map { $0.toDict() }, // Преобразуем ветки в словарь
            "reviews": course.reviews.map { $0.toDict() }, // Преобразуем отзывы в словарь
            "completedBranches": course.completedBranches, // Завершенные ветки курса
            "purchasedBy": course.purchasedBy // Сохраняем массив пользователей, купивших курс (пока пустой при создании)
        ]

        db.collection("courses").document(course.id).setData(courseData) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка сохранения курса: \(error.localizedDescription)")
            }
        }
    }
    
    // Обновление курса
    func updateCourse(title: String, description: String, price: Double, currency: Currency) {
        guard !course.id.isEmpty else { return }
        
        db.collection("courses").document(course.id).updateData([
            "title": title,
            "description": description,
            "price": price,
            "currency": currency.rawValue // Сохраняем значение валюты как строку
        ]) { error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка обновления курса: \(error.localizedDescription)")
            } else {
                self.course.title = title
                self.course.description = description
                self.course.price = price
                self.course.currency = currency // Обновляем курс с новой валютой
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
