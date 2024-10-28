import SwiftUI

struct AddBranchView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var branchTitle = ""
    @State private var branchDescription = ""
    @State private var showAlert = false // состояние для отображения алерта
    
    var body: some View {
        VStack(spacing: 16) {
            // Поле для ввода названия ветки
            TextField("branch_name_placeholder", text: $branchTitle) // Локализованный placeholder
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .foregroundColor(.black)
            
            // Текстовый редактор для описания ветки
            VStack(alignment: .leading) {
                Text("branch_description_title") // Локализованный заголовок для описания
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                TextEditor(text: $branchDescription)
                    .frame(height: 150)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            
            // Кнопка для добавления ветки
            Button(action: {
                viewModel.addBranch(title: branchTitle, description: branchDescription)
                
                // Очищаем поля после добавления ветки
                branchTitle = ""
                branchDescription = ""
                
                // Показываем уведомление
                showAlert = true
            }) {
                Text("add_branch_button") // Локализованный текст для кнопки
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all))
        .navigationTitle("add_branch_title") // Локализованный заголовок экрана
        // Настройка алерта
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("branch_added_alert_title"), // Локализованный заголовок для алерта
                message: Text("branch_added_alert_message"), // Локализованное сообщение для алерта
                dismissButton: .default(Text("ok_button")) // Локализованная кнопка OK
            )
        }
    }
}
