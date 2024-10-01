import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var viewModel: UserViewModel = UserViewModel()
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                // Экран загрузки
                VStack {
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(1.5)
                }
                .onAppear {
                    checkAuthentication()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Черный фон на весь экран
            } else {
                VStack {
                    if viewModel.isAuthenticated {
                        // Интерфейс в зависимости от роли
                        if let role = viewModel.user?.role {
                            if role == "blogger" {
                                BloggerTabView(userViewModel: viewModel)
                            } else {
                                UserTabView(userViewModel: viewModel)
                            }
                        }
                    } else {
                        // Экран входа/регистрации
                        VStack {
                            Text("CoursesStack")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                                .padding(.bottom, 30)
                            
                            authSection
                                .padding()
                                .background(Color(white: 0.15))
                                .cornerRadius(16)
                                .shadow(radius: 10)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40) // Отступ сверху
                        .background(Color.black.edgesIgnoringSafeArea(.all)) // Черный фон для всего экрана
                    }
                }
                .foregroundColor(.white)
            }
        }
    }
    
    // Проверка аутентификации пользователя
    func checkAuthentication() {
        if Auth.auth().currentUser != nil {
            // Если пользователь авторизован, загружаем его роль
            viewModel.fetchUserRole {
                self.isLoading = false
            }
        } else {
            // Если пользователь не авторизован
            self.isLoading = false
        }
    }
    
    // Секция входа/регистрации
    var authSection: some View {
        VStack(spacing: 20) {
            Text("Войдите или зарегистрируйтесь")
                .font(.title2)
                .foregroundColor(.white)
                .bold()
                .padding(.bottom, 20)
            
            NavigationLink(destination: LoginView(viewModel: viewModel)) {
                Text("Войти")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
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
