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
                .foregroundColor(.black) // Изменение цвета текста на черный (или любой другой)
            
            // Текстовый редактор для описания ветки
            VStack(alignment: .leading) {
                Text("Описание ветки")
                    .font(.headline)
                    .foregroundColor(.white) // Белый цвет текста заголовка
                    .padding(.horizontal)
                
                TextEditor(text: $branchDescription)
                    .frame(height: 150) // Устанавливаем высоту редактора
                    .padding(.horizontal)
                    .foregroundColor(.black) // Изменение цвета текста на черный (или любой другой)
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255)) // Цвет для поля ввода
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
                Text("Добавить ветку")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                    .foregroundColor(.white) // Белый цвет текста кнопки
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all)) // Темный фон для экрана
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
