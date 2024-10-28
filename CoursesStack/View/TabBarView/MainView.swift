import SwiftUI

struct MainView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var profileViewModel = ProfileViewModel() // Используем ProfileViewModel отдельно
    
    var body: some View {
        if profileViewModel.isAuthenticated {
            // Проверяем роль и отображаем нужный интерфейс
            if let role = userViewModel.user?.role {
                if role == "blogger" {
                    BloggerTabView(userViewModel: userViewModel) // Передаем userViewModel
                } else {
                    UserTabView(userViewModel: userViewModel) // Передаем userViewModel
                }
            } else {
                // Пока загружаются данные пользователя
                ProgressView(NSLocalizedString("loading_message", comment: "")) // Локализованное сообщение "Загрузка..."
            }
        } else {
            // Если не авторизован, показываем экраны логина/регистрации
            ContentView(viewModel: userViewModel)
        }
    }
}
