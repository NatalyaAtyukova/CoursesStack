import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var authorName: String = "" // Имя автора (для блогеров)
    @Published var isAuthenticated: Bool = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore() // Инициализируем Firestore
    
    init() {
        fetchProfile()
    }
    
    // Получение профиля пользователя
    func fetchProfile() {
        if let currentUser = auth.currentUser {
            self.userEmail = currentUser.email ?? "Неизвестно"
            self.isAuthenticated = true
            
            // Загрузка дополнительных данных пользователя из Firestore
            let userID = currentUser.uid
            db.collection("users").document(userID).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    print("Данные профиля из Firestore: \(data)") // Отладка данных
                    
                    // Если это блогер, загружаем имя автора
                    if let authorName = data["name"] as? String {
                        self.authorName = authorName
                        print("Имя автора: \(authorName)") // Отладка
                    } else {
                        print("Имя автора не найдено в документе")
                    }
                } else {
                    print("Ошибка получения профиля из Firestore: \(error?.localizedDescription ?? "Неизвестно")")
                }
            }
            
        } else {
            self.isAuthenticated = false
        }
    }
    
    // Выход из системы
    func logout() {
        do {
            try auth.signOut()
            self.isAuthenticated = false
        } catch {
            print("Ошибка при выходе: \(error.localizedDescription)")
        }
    }
}
