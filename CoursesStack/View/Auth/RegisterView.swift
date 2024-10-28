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
            Color(red: 28/255, green: 28/255, blue: 30/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("register_title") // Локализованный заголовок
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                
                TextField("email_placeholder", text: $email) // Локализованный placeholder для Email
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                
                SecureField("password_placeholder", text: $password) // Локализованный placeholder для пароля
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(white: 0.9))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                
                Picker("role_picker", selection: $selectedRole) { // Локализованный текст для выбора роли
                    Text("user_role").tag("user") // Локализованный текст для "Пользователь"
                    Text("blogger_role").tag("blogger") // Локализованный текст для "Блогер"
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(red: 235/255, green: 64/255, blue: 52/255).opacity(0.8))
                .cornerRadius(8)
                
                // Поле для имени пользователя, если роль "user"
                if selectedRole == "user" {
                    TextField("username_placeholder", text: $userName) // Локализованный placeholder для имени пользователя
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .autocapitalization(.words)
                }
                
                // Поле для имени автора, если роль "blogger"
                if selectedRole == "blogger" {
                    TextField("authorname_placeholder", text: $authorName) // Локализованный placeholder для имени автора
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(white: 0.9))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .autocapitalization(.words)
                }
                
                Button(action: register) {
                    Text("register_button") // Локализованный текст для кнопки
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage) // Сообщение об ошибке, выводимое как есть
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
            self.errorMessage = NSLocalizedString("user_name_error", comment: "Error message for empty username")
            return
        }
        
        if selectedRole == "blogger" && authorName.isEmpty {
            self.errorMessage = NSLocalizedString("author_name_error", comment: "Error message for empty author name")
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
