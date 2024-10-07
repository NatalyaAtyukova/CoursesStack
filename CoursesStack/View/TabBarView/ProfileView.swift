import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Профиль")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            // Отображение email пользователя
            if viewModel.isAuthenticated {
                Text("Email: \(viewModel.userEmail)")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                
                // Отображение имени в зависимости от роли
                if viewModel.role == "blogger" && !viewModel.authorName.isEmpty {
                    Text("Имя автора: \(viewModel.authorName)")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                } else if viewModel.role == "user" && !viewModel.userName.isEmpty {
                    Text("Имя пользователя: \(viewModel.userName)")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                } else {
                    Text("Роль не указана или имя отсутствует.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
                
            } else {
                Text("Вы не авторизованы")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
            
            // Кнопка выхода
            Button(action: {
                viewModel.logout()
            }) {
                Text("Выйти")
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
