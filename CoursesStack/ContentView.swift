import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var viewModel: UserViewModel = UserViewModel()
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            if isLoading {
                // Показать индикатор загрузки, пока проверяем сессию
                VStack {
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(1.5)
                }
                .onAppear {
                    checkAuthentication()
                }
            } else {
                VStack {
                    if viewModel.isAuthenticated {
                        // Переход к нужному интерфейсу в зависимости от роли
                        if let role = viewModel.user?.role {
                            if role == "blogger" {
                                BloggerTabView(userViewModel: viewModel) // Передаем правильный параметр userViewModel
                            } else {
                                UserTabView(userViewModel: viewModel) // Интерфейс для пользователя с TabBar
                            }
                        }
                    } else {
                        // Экран для входа/регистрации
                        VStack {
                            Text("CoursesStack")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красный цвет для заголовка
                                .padding(.bottom, 30)
                            
                            authSection
                                .padding()
                                .background(Color(white: 0.15)) // Темный фон для секции авторизации
                                .cornerRadius(16)
                                .shadow(radius: 10)
                                .padding()
                        }
                    }
                }
                .navigationBarTitle("Курсы", displayMode: .inline) // Изменяем заголовок на "Курсы"
                .foregroundColor(.white)
            }
        }
    }
    
    // Проверка аутентификации пользователя
    func checkAuthentication() {
        if Auth.auth().currentUser != nil {
            // Если пользователь авторизован, загружаем его роль
            viewModel.fetchUserRole {
                self.isLoading = false // Заканчиваем загрузку
            }
        } else {
            // Если пользователь не авторизован
            self.isLoading = false
        }
    }
    
    var authSection: some View {
        VStack(spacing: 20) {
            Text("Войдите или зарегистрируйтесь")
                .font(.title2)
                .foregroundColor(.white) // Белый текст для контраста
                .bold()
                .padding(.bottom, 20)
            
            NavigationLink(destination: LoginView(viewModel: viewModel)) {
                Text("Войти")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            NavigationLink(destination: RegisterView(viewModel: viewModel)) {
                Text("Зарегистрироваться")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black) // Черная кнопка для регистрации
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding()
    }
}
