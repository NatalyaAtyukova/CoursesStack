import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var viewModel: UserViewModel = UserViewModel() // Подключаем ViewModel
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                if let role = viewModel.user?.role {
                    if role == "blogger" {
                        BloggerDashboardView() // Экран для блогера
                    } else {
                        UserCoursesView() // Экран для обычного пользователя
                    }
                }
            } else {
                // Показываем регистрацию или вход
                NavigationView {
                    VStack {
                        NavigationLink("Login", destination: LoginView(viewModel: viewModel))
                            .padding()
                        
                        NavigationLink("Register", destination: RegisterView(viewModel: viewModel))
                            .padding()
                        
                    }
                }
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                viewModel.fetchUserRole()
            }
        }
    }
}
