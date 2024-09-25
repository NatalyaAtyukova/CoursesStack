import SwiftUI

struct CourseDetailView: View {
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var isEditing = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newPrice = ""
    @State private var showingAddBranch = false
    @State private var showingAddLesson = false
    @State private var selectedBranchID: String?
    
    @State private var selectedLesson: Lesson?
    @State private var showingLessonDetail = false

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
        .navigationBarTitleDisplayMode(.inline)  // Используем встроенный заголовок для уменьшения отступа
        .background(Color(UIColor.systemGroupedBackground))
        .alert(item: $viewModel.errorMessage) { alertMessage in
            Alert(title: Text("Ошибка"), message: Text(alertMessage.message), dismissButton: .default(Text("ОК")))
        }
        .fullScreenCover(isPresented: $viewModel.isDeleted) {
            deletionScreen
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(viewModel: LessonDetailViewModel(lesson: lesson, courseService: CourseService()))
        }
    }

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

            HStack {
                Button(action: {
                    if let price = Double(newPrice) {
                        viewModel.updateCourse(title: newTitle, description: newDescription, price: price)
                        isEditing = false
                    }
                }) {
                    Text("Сохранить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
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
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
        }
    }

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
                .padding(.top, 8)
            
            Text(viewModel.course.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .padding(.bottom, 8)
            
            Text("Цена: \(viewModel.course.price, specifier: "%.2f") руб.")
                .font(.title2)
                .foregroundColor(.green)
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
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .sheet(isPresented: $showingAddLesson) {
                            if let branchID = selectedBranchID {
                                AddLessonView(branchID: branchID, viewModel: viewModel)
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

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                newTitle = viewModel.course.title
                newDescription = viewModel.course.description
                newPrice = "\(viewModel.course.price)"
                isEditing = true
            }) {
                Text("Редактировать")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
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
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 16)
    }
    
    private var addBranchButton: some View {
        Button(action: {
            showingAddBranch.toggle()
        }) {
            Text("Добавить ветку")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .sheet(isPresented: $showingAddBranch) {
            AddBranchView(viewModel: viewModel)
        }
    }

    private var deletionScreen: some View {
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
            .cornerRadius(10)
        }
    }
}