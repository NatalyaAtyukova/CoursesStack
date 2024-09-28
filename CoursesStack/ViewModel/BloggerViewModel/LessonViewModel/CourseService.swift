import Combine
import Firebase
import FirebaseStorage

class CourseService {
    
    private let databaseRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    
    // Получение курса с ветками и уроками
    func fetchCourse(courseID: String) -> AnyPublisher<Course, Error> {
        return Future { promise in
            self.databaseRef.child("courses").child(courseID).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let course = self.parseCourseData(value) else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить данные курса"])))
                    return
                }
                promise(.success(course))
            } withCancel: { error in
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Добавление урока в ветку
    func addLesson(toBranch branchID: String, lesson: Lesson) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let lessonData = self.createLessonData(lesson)
            self.databaseRef.child("branches").child(branchID).child("lessons").child(lesson.id).setValue(lessonData) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Обновление урока
    func updateLesson(_ lesson: Lesson) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let lessonData = self.createLessonData(lesson)
            self.databaseRef.child("lessons").child(lesson.id).updateChildValues(lessonData) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Удаление урока
    func deleteLesson(_ lessonID: String) -> AnyPublisher<Void, Error> {
        print("Удаление урока с ID: \(lessonID)") // Для отладки
        return Future { promise in
            self.databaseRef.child("lessons").child(lessonID).removeValue { error, _ in
                if let error = error {
                    print("Ошибка при удалении урока из Firebase: \(error.localizedDescription)") // Для отладки
                    promise(.failure(error))
                } else {
                    print("Урок успешно удален из Firebase") // Для отладки
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Загрузка файла для урока (например, видео или ресурс)
    func uploadFile(forLesson lessonID: String, fileData: Data, fileName: String) -> AnyPublisher<String, Error> {
        return Future { promise in
            let storagePath = "lessons/\(lessonID)/\(fileName)"
            let fileRef = self.storageRef.child(storagePath)
            
            fileRef.putData(fileData, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                fileRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let url = url {
                        promise(.success(url.absoluteString))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Парсинг данных курса из Firebase
    private func parseCourseData(_ data: [String: Any]) -> Course? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let price = data["price"] as? Double,
              let currencyString = data["currency"] as? String,
              let currency = Currency(rawValue: currencyString), // Преобразование строки в перечисление
              let authorID = data["authorID"] as? String,
              let authorName = data["authorName"] as? String,
              let coverImageURL = data["coverImageURL"] as? String,
              let branchesData = data["branches"] as? [[String: Any]] // Ветки парсим как массив
        else {
            return nil
        }

        // Парсинг веток
        let branches = branchesData.compactMap { branchData in
            return self.parseBranchData(branchData) // Парсим каждую ветку
        }

        let reviews: [Review] = [] // Или парсинг, если данные есть в базе

        // Возвращаем объект курса с данными
        return Course(id: id, title: title, description: description, price: price, currency: currency, coverImageURL: coverImageURL, authorID: authorID, authorName: authorName, branches: branches, reviews: reviews)
    }
    
    // Парсинг данных ветки курса
    private func parseBranchData(_ data: [String: Any]) -> CourseBranch? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let lessonsData = data["lessons"] as? [String: Any] else { return nil }
        
        let lessons = lessonsData.compactMap { (key, value) -> Lesson? in
            guard let lessonData = value as? [String: Any] else { return nil }
            return self.parseLessonData(lessonData)
        }
        
        return CourseBranch(id: id, title: title, description: description, lessons: lessons)
    }
    
    // Парсинг данных урока
    private func parseLessonData(_ data: [String: Any]) -> Lesson? {
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let content = data["content"] as? String else { return nil }
        
        return Lesson(id: id, title: title, content: content, videoURL: data["videoURL"] as? String ?? "", assignments: [], downloadableFiles: [])
    }
    
    // Преобразование данных урока в формат для Firebase
    private func createLessonData(_ lesson: Lesson) -> [String: Any] {
        return [
            "id": lesson.id,
            "title": lesson.title,
            "content": lesson.content,
            "videoURL": lesson.videoURL ?? ""
        ]
    }
}
