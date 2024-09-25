import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Профиль")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            // Отображение email пользователя
            if viewModel.isAuthenticated {
                Text("Email: \(viewModel.userEmail)")
                    .font(.title2)
                    .padding()
                
                // Отображение имени автора для блогеров
                if !viewModel.authorName.isEmpty {
                    Text("Имя автора: \(viewModel.authorName)")
                        .font(.title3)
                        .padding(.top, 10)
                } else {
                    Text("Вы не блогер или имя автора не указано.")
                        .font(.title3)
                        .padding(.top, 10)
                }
                
            } else {
                Text("Вы не авторизованы")
                    .font(.title2)
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
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchProfile()
        }
    }
}