import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "user" // По умолчанию роль пользователя
    @State private var authorName = "" // Имя автора для роли "blogger"
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 30/255) // Мягкий темно-серый фон
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Регистрация")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255)) // Более мягкий красный
                
                TextField("Email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9)) // Светлый серый фон для текстовых полей
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                
                SecureField("Пароль", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                
                // Добавляем выбор роли
                Picker("Выберите вашу роль", selection: $selectedRole) {
                    Text("Пользователь").tag("user")
                    Text("Блогер").tag("blogger")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(red: 235/255, green: 64/255, blue: 52/255).opacity(0.8)) // Мягкий красный для выбора роли
                .cornerRadius(8)
                
                // Поле для имени автора, отображается только если роль "blogger"
                if selectedRole == "blogger" {
                    TextField("Имя автора", text: $authorName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(white: 0.9)) // Светлый серый фон для текстовых полей
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .autocapitalization(.words)
                }
                
                Button(action: register) {
                    Text("Регистрация")
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
    
    func register() {
        // Передаем authorName только если роль "blogger"
        viewModel.register(email: email, password: password, role: selectedRole, authorName: selectedRole == "blogger" ? authorName : nil) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
