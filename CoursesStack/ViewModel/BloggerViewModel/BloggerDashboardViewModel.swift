import Foundation
import FirebaseFirestore
import FirebaseAuth

class BloggerDashboardViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var errorMessage: AlertMessage? // Используем AlertMessage для обработки ошибок
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid
    
    // Загрузка курсов блогера
    func fetchCourses() {
        guard let userID = userID else { return }
        
        db.collection("courses")
            .whereField("authorID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = AlertMessage(message: "Ошибка загрузки курсов: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    self.courses = snapshot.documents.compactMap { doc in
                        let data = doc.data()
                        return Course(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0.0,
                            coverImageURL: data["coverImageURL"] as? String ?? "",
                            authorID: data["authorID"] as? String ?? "",
                            authorName: data["authorName"] as? String ?? "",
                            branches: data["branches"] as? [CourseBranch] ?? [], // Пустой массив по умолчанию
                            reviews: [] // Пустой массив отзывов
                        )
                    }
                }
            }
    }
    

    // Создание нового курса с URL изображения обложки
    func createCourse(title: String, description: String, price: Double, currency: String, coverImageURL: String, authorID: String, authorName: String) {
        guard let userID = userID else { return }
        
        // Сначала загрузим имя пользователя из коллекции "users" по userID
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = AlertMessage(message: "Ошибка получения имени автора: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(), let authorName = data["name"] as? String else {
                self.errorMessage = AlertMessage(message: "Не удалось получить имя автора.")
                return
            }
            
            let newCourse = [
                "title": title,
                "description": description,
                "price": price,
                "currency": currency, // Сохранение валюты
                "coverImageURL": coverImageURL, // Сохранение URL изображения
                "authorID": userID,
                "authorName": authorName, // Сохранение имени автора
                "branches": [], // Пустой массив веток
                "reviews": [] // Пустой массив отзывов
            ] as [String: Any]
            
            // Сохраняем новый курс в коллекцию "courses"
            self.db.collection("courses").addDocument(data: newCourse) { error in
                if let error = error {
                    self.errorMessage = AlertMessage(message: "Ошибка создания курса: \(error.localizedDescription)")
                } else {
                    self.fetchCourses() // Обновление списка курсов
                }
            }
        }
    }
}
