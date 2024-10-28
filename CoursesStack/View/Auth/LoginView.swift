import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: UserViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 30/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("login_title") // Локализованный заголовок
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
                
                Button(action: login) {
                    Text("login_button") // Локализованный текст для кнопки
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                if !errorMessage.isEmpty {
                    Text("login_error") // Локализованное сообщение об ошибке
                        .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
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
                self.errorMessage = NSLocalizedString("login_error", comment: "Login error message") // Локализация ошибки
            }
        }
    }
}
