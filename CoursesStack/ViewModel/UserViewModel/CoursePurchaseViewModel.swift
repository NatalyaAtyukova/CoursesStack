import Foundation
import FirebaseFirestore
import FirebaseAuth

class CoursePurchaseViewModel: ObservableObject {
    @Published var course: Course
    @Published var isPurchased: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()

    init(course: Course) {
        self.course = course
        checkIfPurchased() // Проверяем, куплен ли курс
    }

    // Проверка, куплен ли курс
    func checkIfPurchased() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться"
            return
        }

        // Проверяем, есть ли ID пользователя в списке купивших курс
        isPurchased = course.purchasedBy.contains(userID)
    }

    // Метод для покупки курса
    func purchaseCourse() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Необходимо авторизоваться для покупки"
            return
        }

        // Если курс уже куплен, выводим сообщение об ошибке
        if isPurchased {
            self.errorMessage = "Этот курс уже куплен"
            return
        }

        // Обновляем базу данных Firestore, добавляя пользователя в список купивших
        db.collection("courses").document(course.id).updateData([
            "purchasedBy": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                self.errorMessage = "Ошибка при покупке курса: \(error.localizedDescription)"
            } else {
                // Обновляем локальные данные
                self.course.purchasedBy.append(userID)
                self.isPurchased = true
            }
        }
    }
}
