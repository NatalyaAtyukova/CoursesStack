import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "user" // По умолчанию роль пользователя
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Добавляем выбор роли
            Picker("Выберите вашу роль", selection: $selectedRole) {
                Text("Пользователь").tag("user")
                Text("Блогер").tag("blogger")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button(action: register) {
                Text("Register")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
    func register() {
        viewModel.register(email: email, password: password, role: selectedRole) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
