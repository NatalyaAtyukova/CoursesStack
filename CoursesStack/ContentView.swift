import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var viewModel: UserViewModel = UserViewModel() // Подключаем ViewModel
    @State private var isLoading = true // Флаг для состояния загрузки
    
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
                    // Проверка на наличие авторизованного пользователя
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
            } else {
                VStack {
                    if viewModel.isAuthenticated {
                        // Переход к нужному интерфейсу в зависимости от роли
                        if let role = viewModel.user?.role {
                            if role == "blogger" {
                                BloggerDashboardView() // Экран для блогера
                            } else {
                                UserCoursesView() // Экран для обычного пользователя
                            }
                        }
                    } else {
                        // Экран для входа/регистрации
                        VStack {
                            Text("CoursesStack")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255)) // Мягкий красный цвет для названия
                                .padding(.bottom, 30) // Отступ между заголовком и формой
                            
                            authSection
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(16)
                                .shadow(radius: 10)
                                .padding()
                        }
                    }
                }
                .navigationBarTitle("Добро пожаловать", displayMode: .inline)
                .onAppear {
                    // Проверяем, если пользователь уже авторизован при старте
                    if Auth.auth().currentUser != nil {
                        viewModel.fetchUserRole()
                    }
                }
            }
        }
    }
    
    var authSection: some View {
        VStack(spacing: 20) {
            Text("Войдите или зарегистрируйтесь")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            NavigationLink(destination: LoginView(viewModel: viewModel)) {
                Text("Войти")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красный акцент на кнопке
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            NavigationLink(destination: RegisterView(viewModel: viewModel)) {
                Text("Зарегистрироваться")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding()
    }
}
