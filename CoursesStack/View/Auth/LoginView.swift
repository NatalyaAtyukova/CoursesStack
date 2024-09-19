import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 30/255) // Мягкий темно-серый фон
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Вход")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255)) // Более мягкий красный
                
                TextField("Email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9)) // Светлый серый фон текстовых полей
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                
                SecureField("Пароль", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                
                Button(action: login) {
                    Text("Войти")
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Мягкий красный цвет для кнопки
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255)) // Мягкий красный цвет для ошибок
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    func login() {
        viewModel.login(email: email, password: password) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
