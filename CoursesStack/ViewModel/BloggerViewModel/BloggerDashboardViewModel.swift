import Foundation
import FirebaseFirestore
import FirebaseAuth

class BloggerDashboardViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var errorMessage: AlertMessage? // Используем AlertMessage для обработки ошибок
    
    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid
    
    // Загрузка курсов блогера с обновленной структурой данных
    func fetchCourses() {
        guard let userID = userID else { return }
        
        db.collection("courses")
            .whereField("authorID", isEqualTo: userID)
            .getDocuments(source: .default) { snapshot, error in
                if let error = error {
                    self.errorMessage = AlertMessage(message: "Ошибка загрузки курсов: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    self.courses = snapshot.documents.compactMap { doc in
                        let data = doc.data()
                        
                        // Отладочные сообщения для диагностики
                        print("Document data for course \(doc.documentID): \(data)")
                        
                        // Загрузка веток курсов
                        let branchesData = data["branches"] as? [[String: Any]] ?? []
                        let branches: [CourseBranch] = branchesData.compactMap { branchData in
                            print("Branch data for course \(doc.documentID): \(branchData)")
                            let lessonsData = branchData["lessons"] as? [[String: Any]] ?? []
                            let lessons: [Lesson] = lessonsData.compactMap { lessonData in
                                print("Lesson data: \(lessonData)")
                                
                                let assignmentsData = lessonData["assignments"] as? [[String: Any]] ?? []
                                let assignments: [Assignment] = assignmentsData.compactMap { assignmentData in
                                    print("Assignment data: \(assignmentData)")
                                    return Assignment(
                                        id: assignmentData["id"] as? String ?? UUID().uuidString,
                                        title: assignmentData["title"] as? String ?? "",
                                        type: AssignmentType(rawValue: assignmentData["type"] as? String ?? "") ?? .multipleChoice,
                                        choices: assignmentData["choices"] as? [String] ?? [],
                                        correctAnswer: assignmentData["correctAnswer"] as? String ?? ""
                                    )
                                }
                                
                                let downloadableFilesData = lessonData["downloadableFiles"] as? [[String: Any]] ?? []
                                let downloadableFiles: [DownloadableFile] = downloadableFilesData.compactMap { fileData in
                                    DownloadableFile(
                                        id: fileData["id"] as? String ?? UUID().uuidString,
                                        fileName: fileData["fileName"] as? String ?? "",
                                        fileURL: fileData["fileURL"] as? String ?? ""
                                    )
                                }
                                
                                return Lesson(
                                    id: lessonData["id"] as? String ?? UUID().uuidString,
                                    title: lessonData["title"] as? String ?? "",
                                    content: lessonData["content"] as? String ?? "",
                                    videoURL: lessonData["videoURL"] as? String,
                                    assignments: assignments,
                                    downloadableFiles: downloadableFiles
                                )
                            }
                            
                            return CourseBranch(
                                id: branchData["id"] as? String ?? UUID().uuidString,
                                title: branchData["title"] as? String ?? "",
                                description: branchData["description"] as? String ?? "",
                                lessons: lessons
                            )
                        }
                        
                        // Загрузка отзывов
                        let reviewsData = data["reviews"] as? [[String: Any]] ?? []
                        let reviews: [Review] = reviewsData.compactMap { reviewData in
                            print("Review data for course \(doc.documentID): \(reviewData)")
                            return Review(
                                id: reviewData["id"] as? String ?? UUID().uuidString,
                                userID: reviewData["userID"] as? String ?? "",
                                content: reviewData["content"] as? String ?? "",
                                rating: reviewData["rating"] as? Int ?? 0
                            )
                        }
                        
                        // Инициализация completedBranches (например, пустое состояние)
                        let completedBranches = data["completedBranches"] as? [String: Bool] ?? [:]
                        let purchasedBy = data["purchasedBy"] as? [String] ?? []

                        return Course(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0.0,
                            currency: Currency(rawValue: data["currency"] as? String ?? "") ?? .dollar,
                            coverImageURL: data["coverImageURL"] as? String ?? "",
                            authorID: data["authorID"] as? String ?? "",
                            authorName: data["authorName"] as? String ?? "",
                            branches: branches,
                            reviews: reviews,
                            completedBranches: completedBranches,
                            purchasedBy: purchasedBy
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
