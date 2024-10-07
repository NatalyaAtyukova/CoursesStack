import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "user"  // По умолчанию роль пользователя
    @State private var authorName = ""        // Имя автора для роли "blogger"
    @State private var userName = ""          // Имя пользователя для роли "user"
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 30/255)  // Мягкий темно-серый фон
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Регистрация")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))  // Мягкий красный цвет
                
                TextField("Email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                
                SecureField("Пароль", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                
                // Выбор роли
                Picker("Выберите вашу роль", selection: $selectedRole) {
                    Text("Пользователь").tag("user")
                    Text("Блогер").tag("blogger")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(red: 235/255, green: 64/255, blue: 52/255).opacity(0.8))
                .cornerRadius(8)
                
                // Поле для имени пользователя, отображается, если роль "user"
                if selectedRole == "user" {
                    TextField("Имя пользователя", text: $userName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .autocapitalization(.words)
                }
                
                // Поле для имени автора, отображается, если роль "blogger"
                if selectedRole == "blogger" {
                    TextField("Имя автора", text: $authorName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .autocapitalization(.words)
                }
                
                Button(action: register) {
                    Text("Регистрация")
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    func register() {
        // Проверка на заполнение имени в зависимости от роли
        if selectedRole == "user" && userName.isEmpty {
            self.errorMessage = "Введите имя пользователя."
            return
        }
        
        if selectedRole == "blogger" && authorName.isEmpty {
            self.errorMessage = "Введите имя автора."
            return
        }
        
        // Передаем authorName или userName в зависимости от выбранной роли
        let name = selectedRole == "blogger" ? authorName : userName
        
        viewModel.register(email: email, password: password, role: selectedRole, name: name) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
