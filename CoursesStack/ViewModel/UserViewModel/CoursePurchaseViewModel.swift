import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class CoursePurchaseViewModel: ObservableObject {
    @Published var course: Course
    @Published var isPurchased: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init(course: Course) {
        self.course = course
        print("Инициализация CoursePurchaseViewModel с course.id: \(course.id)") // Проверяем, какой ID передан
        checkIfPurchased()
    }
    
    func checkIfPurchased() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться"
            return
        }
        
        isPurchased = course.purchasedBy.contains(userID)
    }
    
    func purchaseCourse() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться для покупки"
            return
        }
        
        if isPurchased {
            self.errorMessage = "Этот курс уже куплен"
            return
        }
        
        // Печатаем ID перед обращением к Firestore
        print("Попытка обновить документ с ID курса: \(course.id)")
        
        let courseRef = db.collection("courses").document(course.id)
        
        courseRef.getDocument { [weak self] (document, error) in
            if let error = error {
                self?.errorMessage = "Ошибка при доступе к данным курса: \(error.localizedDescription)"
                return
            }
            
            if let document = document, document.exists {
                courseRef.updateData([
                    "purchasedBy": FieldValue.arrayUnion([userID])
                ]) { error in
                    if let error = error {
                        self?.errorMessage = "Ошибка при покупке курса: \(error.localizedDescription)"
                    } else {
                        self?.course.purchasedBy.append(userID)
                        self?.isPurchased = true
                        self?.errorMessage = nil
                        print("Курс успешно куплен!")
                    }
                }
            } else {
                self?.errorMessage = "Курс с указанным ID не найден: \(self?.course.id ?? "")"
                print("Курс с ID \(self?.course.id ?? "") не найден.")
            }
        }
    }
}
