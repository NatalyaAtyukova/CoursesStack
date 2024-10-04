import SwiftUI

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @Environment(\.presentationMode) var presentationMode  // Для возврата назад
    @State private var isEditing = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newPrice = ""
    @State private var newCurrency: Currency = .ruble  // Для выбора валюты
    @State private var showingAddBranch = false
    @State private var showingAddLesson = false
    @State private var selectedBranchID: String?
    
    @State private var selectedLesson: Lesson?
    @State private var showingLessonDetail = false
    @Environment(\.dismiss) var dismiss  // Используем для закрытия экрана после удаления курса

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                if isEditing {
                    editingSection
                } else {
                    courseDetailSection
                }
                
                if !isEditing {
                    actionButtons
                }
            }
            .padding()
        }
        .navigationTitle("Управление курсом")
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для экрана
        .alert(item: $viewModel.errorMessage) { alertMessage in
            Alert(title: Text("Ошибка"), message: Text(alertMessage.message), dismissButton: .default(Text("ОК")))
        }
        .onChange(of: viewModel.isDeleted) { isDeleted in
            if isDeleted {
                dismiss()  // Возвращаемся к списку курсов после удаления
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(viewModel: LessonDetailViewModel(lesson: lesson, courseService: CourseService()))
        }
    }

    // Секция редактирования курса
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField("Название", text: $newTitle)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            TextField("Описание", text: $newDescription)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            TextField("Цена", text: $newPrice)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            Picker("Валюта", selection: $newCurrency) {
                ForEach(Currency.allCases, id: \.self) { currency in
                    Text(currency.rawValue).tag(currency)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Button(action: {
                    if let price = Double(newPrice) {
                        viewModel.updateCourse(title: newTitle, description: newDescription, price: price, currency: newCurrency)
                        isEditing = false
                    }
                }) {
                    Text("Сохранить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                
                Button(action: {
                    isEditing = false
                }) {
                    Text("Отменить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
        }
    }

    // Секция отображения деталей курса
    private var courseDetailSection: some View {
        VStack(alignment: .center, spacing: 16) {
            if let imageURL = URL(string: viewModel.course.coverImageURL) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .clipped()
                            .shadow(radius: 5)
                            .frame(maxWidth: .infinity)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Text(viewModel.course.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            Text(viewModel.course.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text("Цена: \(viewModel.course.price, specifier: "%.2f") \(viewModel.course.currency.symbol)")
                .font(.title2)
                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                .padding(.top, 8)
            
            Divider()
            
            Text("Шаги курса")
                .font(.headline)
                .padding(.bottom, 8)
            
            if !viewModel.course.branches.isEmpty {
                ForEach(viewModel.course.branches) { branch in
                    VStack(alignment: .leading, spacing: 10) {
                        BranchCard(
                            branch: branch,
                            isCompleted: viewModel.course.completedBranches[branch.id] ?? false,
                            description: branch.description,
                            onLessonTap: { lesson in
                                selectedLesson = lesson
                                showingLessonDetail = true
                            }
                        )
                        
                        Text("Уроки:")
                            .font(.subheadline)
                            .padding(.top, 8)
                        
                        ForEach(branch.lessons) { lesson in
                            LessonCard(lesson: lesson)
                                .onTapGesture {
                                    selectedLesson = lesson
                                    showingLessonDetail = true
                                }
                        }
                        
                        Button(action: {
                            selectedBranchID = branch.id
                            showingAddLesson.toggle()
                        }) {
                            Text("Добавить урок")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .sheet(isPresented: $showingAddLesson) {
                            if let branchID = selectedBranchID {
                                AddLessonView(branchID: branchID, branchName: "Имя ветки", viewModel: viewModel)
                            }
                        }
                    }
                }
            } else {
                Text("Нет доступных веток курса")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            addBranchButton
        }
    }

    // Кнопки действий
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                newTitle = viewModel.course.title
                newDescription = viewModel.course.description
                newPrice = "\(viewModel.course.price)"
                newCurrency = viewModel.course.currency  // Устанавливаем текущую валюту
                isEditing = true
            }) {
                Text("Редактировать")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            
            Button(action: {
                viewModel.deleteCourse()
            }) {
                Text("Удалить")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white) // Белый цвет текста
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 16)
    }


    // Кнопка добавления ветки
    private var addBranchButton: some View {
        Button(action: {
            showingAddBranch.toggle()
        }) {
            Text("Добавить ветку")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .sheet(isPresented: $showingAddBranch) {
            AddBranchView(viewModel: viewModel)
        }
    }
    
    // Экран удаления курса
    private var deletionScreen: some View {
        VStack {
            Text("Курс был успешно удален.")
                .font(.headline)
                .foregroundColor(Color.white)  // Белый цвет текста
                .padding()
                .background(Color(red: 44/255, green: 44/255, blue: 46/255))  // Темный фон для текста
                .cornerRadius(10)
            
            NavigationLink(destination: BloggerDashboardView()) {
                Text("Вернуться на панель управления")
                    .padding()
                    .background(Color(red: 0/255, green: 122/255, blue: 255/255))  // Синий фон кнопки
                    .foregroundColor(.white)  // Белый цвет текста кнопки
                    .cornerRadius(10)
                    .shadow(radius: 2)  // Тень для кнопки
            }
        }
        .padding()
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))  // Темный фон для всего экрана
        .cornerRadius(10)
    }
}


