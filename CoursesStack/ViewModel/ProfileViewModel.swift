import FirebaseAuth
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isAuthenticated: Bool = false
    
    private let auth = Auth.auth()
    
    init() {
        fetchProfile()
    }
    
    // Получение профиля пользователя
    func fetchProfile() {
        if let currentUser = auth.currentUser {
            self.userEmail = currentUser.email ?? "Неизвестно"
            self.isAuthenticated = true
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
