import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("profile_title", comment: "")) // Локализованный заголовок "Профиль"
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            // Отображение email пользователя
            if viewModel.isAuthenticated {
                Text(String(format: NSLocalizedString("email_label", comment: ""), viewModel.userEmail)) // Локализованный текст "Email:"
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                
                // Отображение имени в зависимости от роли
                if viewModel.role == "blogger" && !viewModel.authorName.isEmpty {
                    Text(String(format: NSLocalizedString("author_name_label", comment: ""), viewModel.authorName)) // Локализованный текст "Имя автора:"
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                } else if viewModel.role == "user" && !viewModel.userName.isEmpty {
                    Text(String(format: NSLocalizedString("user_name_label", comment: ""), viewModel.userName)) // Локализованный текст "Имя пользователя:"
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                } else {
                    Text(NSLocalizedString("no_role_or_name_message", comment: "")) // Локализованное сообщение "Роль не указана или имя отсутствует."
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                
            } else {
                Text(NSLocalizedString("not_authenticated_message", comment: "")) // Локализованное сообщение "Вы не авторизованы"
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
            
            // Кнопка выхода
            Button(action: {
                viewModel.logout()
            }) {
                Text(NSLocalizedString("logout_button", comment: "")) // Локализованная кнопка "Выйти"
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)
            .edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchProfile()
        }
    }
}
