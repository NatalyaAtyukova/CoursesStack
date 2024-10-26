import FirebaseFirestore
import SwiftUI

class CourseRightsDetailViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var purchasedUsers: [UserModel] = [] // Список пользователей, купивших курс
    @Published var errorMessage: String?

    private let course: Course
    
    init(course: Course) {
        self.course = course
        fetchReviews()
        fetchPurchasedUsers()
    }

    // Получаем отзывы по курсу из отдельной коллекции
    func fetchReviews() {
        let db = Firestore.firestore()
        db.collection("reviews")
            .whereField("courseID", isEqualTo: course.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.reviews = snapshot?.documents.compactMap { document in
                    try? document.data(as: Review.self)
                } ?? []
            }
    }

    // Получаем список пользователей, купивших курс
    func fetchPurchasedUsers() {
        let db = Firestore.firestore()
        
        // Загружаем каждого пользователя по его идентификатору из массива purchasedBy
        let userIDs = course.purchasedBy
        
        for userID in userIDs {
            db.collection("users").document(userID).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let data = snapshot?.data() {
                    if let user = try? snapshot?.data(as: UserModel.self) {
                        DispatchQueue.main.async {
                            self.purchasedUsers.append(user)
                        }
                    }
                }
            }
        }
    }
}
