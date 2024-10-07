import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var authorName: String = ""   // Имя автора (для блогеров)
    @Published var userName: String = ""     // Имя пользователя (для обычных пользователей)
    @Published var isAuthenticated: Bool = false
    @Published var role: String = ""         // Роль пользователя: "user" или "blogger"
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        fetchProfile()
    }
    
    // Получение профиля пользователя
    func fetchProfile() {
        guard let currentUser = auth.currentUser else {
            self.isAuthenticated = false
            return
        }
        
        self.userEmail = currentUser.email ?? "Неизвестно"
        self.isAuthenticated = true
        
        // Загрузка дополнительных данных пользователя из Firestore
        let userID = currentUser.uid
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Ошибка получения профиля из Firestore: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("Документ пользователя пуст или отсутствует")
                return
            }
            
            print("Данные профиля из Firestore: \(data)")  // Отладка данных
            
            // Устанавливаем роль пользователя, если она есть в документе
            if let role = data["role"] as? String {
                self.role = role
                print("Роль пользователя: \(role)")  // Отладка
                
                // Установка имени в зависимости от роли
                if role == "blogger", let authorName = data["name"] as? String {
                    self.authorName = authorName
                    print("Имя автора: \(authorName)")  // Отладка
                } else if role == "user", let userName = data["name"] as? String {
                    self.userName = userName
                    print("Имя пользователя: \(userName)")  // Отладка
                }
            } else {
                print("Роль пользователя не найдена в документе")
            }
        }
    }
    
    // Выход из системы
    func logout() {
        do {
            try auth.signOut()
            self.isAuthenticated = false
            self.userEmail = ""
            self.authorName = ""
            self.userName = ""
            self.role = ""
        } catch {
            print("Ошибка при выходе: \(error.localizedDescription)")
        }
    }
}
