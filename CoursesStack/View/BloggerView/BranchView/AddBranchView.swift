import SwiftUI

struct AddBranchView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var branchTitle = ""
    @State private var branchDescription = ""
    @State private var showAlert = false // состояние для отображения алерта
    
    var body: some View {
        VStack(spacing: 16) {
            // Поле для ввода названия ветки
            TextField("Название ветки", text: $branchTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Текстовый редактор для описания ветки
            VStack(alignment: .leading) {
                Text("Описание ветки")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextEditor(text: $branchDescription)
                    .frame(height: 150) // Устанавливаем высоту редактора
                    .padding(.horizontal)
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
                Text("Добавить ветку")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(white: 0.95).edgesIgnoringSafeArea(.all))
        .navigationTitle("Добавление ветки")
        // Настройка алерта
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Ветка добавлена"),
                message: Text("Ветка успешно создана!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
