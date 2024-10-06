import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: UserModel?
    @Published var selectedCourse: Course?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // Регистрация с ролью и именем автора
    func register(email: String, password: String, role: String, authorName: String?, completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Сохранение пользователя с ролью и (опционально) именем автора в Firestore
            if let userID = result?.user.uid {
                var userData: [String: Any] = [
                    "email": email,
                    "role": role
                ]
                
                // Если роль "blogger", добавляем имя автора
                if role == "blogger", let authorName = authorName {
                    userData["name"] = authorName
                }
                
                self.db.collection("users").document(userID).setData(userData) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        self.isAuthenticated = true
                        self.fetchUserRole {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    // Логин
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            self.isAuthenticated = true
            self.fetchUserRole {
                completion(nil)
            }
        }
    }
    
    // Получение роли пользователя с замыканием
    func fetchUserRole(completion: @escaping () -> Void = {}) {
        guard let userID = auth.currentUser?.uid else {
            completion() // Если пользователь не найден, вызываем завершение
            return
        }
        
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let email = data["email"] as? String ?? ""
                let role = data["role"] as? String ?? "user"
                let authorName = data["name"] as? String ?? "" // Загружаем имя автора, если оно есть
                self.user = UserModel(id: userID, email: email, role: role, authorName: authorName)
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
            completion() // Вызываем завершение после получения данных
        }
    }
}
