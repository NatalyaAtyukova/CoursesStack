import SwiftUI

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var isEditing = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newPrice = ""
    @State private var showingAddBranch = false

    var body: some View {
        VStack {
            if isEditing {
                // Поля для редактирования курса
                TextField("Название", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Описание", text: $newDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Цена", text: $newPrice)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button(action: {
                        if let price = Double(newPrice) {
                            viewModel.updateCourse(title: newTitle, description: newDescription, price: price)
                            isEditing = false
                        }
                    }) {
                        Text("Сохранить")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isEditing = false
                    }) {
                        Text("Отменить")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                // Отображение деталей курса
                AsyncImage(url: URL(string: viewModel.course.coverImageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } placeholder: {
                    ProgressView()
                }
                
                Text(viewModel.course.title)
                    .font(.largeTitle)
                    .padding()
                
                Text(viewModel.course.description)
                    .font(.body)
                    .padding()
                
                Text("Цена: \(viewModel.course.price, specifier: "%.2f") руб.")
                    .font(.title2)
                    .padding()

                // Список веток и уроков
                List(viewModel.course.branches) { branch in
                    Section(header: Text(branch.title)) {
                        ForEach(branch.lessons) { lesson in
                            Text(lesson.title)
                        }
                    }
                }

                // Кнопка для добавления веток
                Button(action: {
                    showingAddBranch.toggle()
                }) {
                    Text("Добавить ветку")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showingAddBranch) {
                    AddBranchView(viewModel: viewModel) // Передаем правильный ViewModel
                }
                .padding()

                Spacer()

                // Кнопки для редактирования и удаления курса
                HStack {
                    Button(action: {
                        // Включаем режим редактирования
                        newTitle = viewModel.course.title
                        newDescription = viewModel.course.description
                        newPrice = "\(viewModel.course.price)"
                        isEditing = true
                    }) {
                        Text("Редактировать")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        viewModel.deleteCourse()
                    }) {
                        Text("Удалить")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Управление курсом")
        .alert(item: $viewModel.errorMessage) { alertMessage in
            Alert(title: Text("Ошибка"), message: Text(alertMessage.message), dismissButton: .default(Text("ОК")))
        }
        .fullScreenCover(isPresented: $viewModel.isDeleted) {
            VStack {
                Text("Курс был успешно удален.")
                    .font(.headline)
                    .padding()
                Button("Вернуться назад") {
                    // Логика для перехода на предыдущий экран
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}
