import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Профиль")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white) // Белый цвет заголовка
                .padding(.top, 40)
            
            // Отображение email пользователя
            if viewModel.isAuthenticated {
                Text("Email: \(viewModel.userEmail)")
                    .font(.title2)
                    .foregroundColor(.white) // Белый цвет текста
                    .padding()
                
                // Отображение имени автора для блогеров
                if !viewModel.authorName.isEmpty {
                    Text("Имя автора: \(viewModel.authorName)")
                        .font(.title3)
                        .foregroundColor(.white) // Белый цвет текста
                        .padding(.top, 10)
                } else {
                    Text("Вы не блогер или имя автора не указано.")
                        .font(.title3)
                        .foregroundColor(.white) // Белый цвет текста
                        .padding(.top, 10)
                }
                
            } else {
                Text("Вы не авторизованы")
                    .font(.title2)
                    .foregroundColor(.white) // Белый цвет текста
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
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                    .foregroundColor(.white) // Белый цвет текста кнопки
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color(white: 0.15)) // Темный фон для экрана
        .onAppear {
            viewModel.fetchProfile()
        }
    }
}
