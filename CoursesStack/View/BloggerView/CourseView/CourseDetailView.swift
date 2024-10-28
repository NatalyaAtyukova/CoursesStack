import SwiftUI

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newPrice = ""
    @State private var newCurrency: Currency = .ruble
    @State private var showingAddBranch = false
    @State private var showingAddLesson = false
    @State private var selectedBranchID: String?
    
    @State private var selectedLesson: Lesson?
    @State private var showingLessonDetail = false
    @Environment(\.dismiss) var dismiss
    
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
        .navigationTitle(NSLocalizedString("course_management_title", comment: "")) // Локализованный заголовок
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
        .alert(item: $viewModel.errorMessage) { alertMessage in
            Alert(title: Text(NSLocalizedString("error_title", comment: "")),
                  message: Text(alertMessage.message),
                  dismissButton: .default(Text(NSLocalizedString("ok_button", comment: ""))))
        }
        .onChange(of: viewModel.isDeleted) { isDeleted in
            if isDeleted {
                dismiss()
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(viewModel: LessonDetailViewModel(lesson: lesson, courseService: CourseService()))
        }
    }
    
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField(NSLocalizedString("title_placeholder", comment: ""), text: $newTitle)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
                .foregroundColor(.black)
            
            TextField(NSLocalizedString("description_placeholder", comment: ""), text: $newDescription)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
                .foregroundColor(.black)
            
            TextField(NSLocalizedString("price_placeholder", comment: ""), text: $newPrice)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
                .foregroundColor(.black)
            
            Picker(NSLocalizedString("currency_picker", comment: ""), selection: $newCurrency) {
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
                    Text(NSLocalizedString("save_button", comment: ""))
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
                    Text(NSLocalizedString("cancel_button", comment: ""))
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
            
            Text(String(format: NSLocalizedString("price_label", comment: ""), viewModel.course.price, viewModel.course.currency.symbol)) // Локализованная строка "Цена"
                .font(.title2)
                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                .padding(.top, 8)
            
            Divider()
            
            Text(NSLocalizedString("course_steps", comment: "")) // Локализованная строка "Шаги курса"
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
                        
                        Text(NSLocalizedString("lessons_label", comment: "")) // Локализованная строка "Уроки"
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
                            Text(NSLocalizedString("add_lesson_button", comment: "")) // Локализованная кнопка "Добавить урок"
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .sheet(isPresented: $showingAddLesson) {
                            if let branchID = selectedBranchID,
                               let branch = viewModel.course.branches.first(where: { $0.id == branchID }) {
                                AddLessonView(branchID: branchID, branchName: branch.title, viewModel: viewModel)
                            }
                        }
                    }
                }
            } else {
                Text(NSLocalizedString("no_branches", comment: "")) // Локализованная строка "Нет доступных веток курса"
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
                newCurrency = viewModel.course.currency
                isEditing = true
            }) {
                Text(NSLocalizedString("edit_button", comment: "")) // Локализованная кнопка "Редактировать"
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
                Text(NSLocalizedString("delete_button", comment: "")) // Локализованная кнопка "Удалить"
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white)
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
            Text(NSLocalizedString("add_branch_button", comment: "")) // Локализованная кнопка "Добавить ветку"
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 235/255, green: 64/255, blue: 52/255))
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
            Text(NSLocalizedString("course_deleted_message", comment: "")) // Локализованное сообщение "Курс был успешно удален"
                .font(.headline)
                .foregroundColor(Color.white)
                .padding()
                .background(Color(red: 44/255, green: 44/255, blue: 46/255))
                .cornerRadius(10)
            
            NavigationLink(destination: BloggerDashboardView()) {
                Text(NSLocalizedString("return_to_dashboard_button", comment: "")) // Локализованная кнопка "Вернуться на панель управления"
                    .padding()
                    .background(Color(red: 0/255, green: 122/255, blue: 255/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .padding()
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
        .cornerRadius(10)
    }
}
