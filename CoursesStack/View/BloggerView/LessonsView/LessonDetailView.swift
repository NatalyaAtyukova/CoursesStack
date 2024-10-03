import SwiftUI
import PhotosUI
import WebKit

struct LessonDetailView: View {
    @ObservedObject var viewModel: LessonDetailViewModel
    @State private var isEditing = false
    @State private var newContent = ""
    @State private var newVideoURL = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var newAssignments = [Assignment]()
    
    @Environment(\.presentationMode) var presentationMode // Чтобы закрыть экран после удаления

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    editingSection
                } else {
                    lessonDetailSection
                }
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Урок: \(viewModel.lesson.title)")
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для всего экрана
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: viewModel.isDeleted) { isDeleted in
            if isDeleted {
                // Закрыть экран после успешного удаления урока
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField("Текст урока", text: $newContent)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)

            Button(action: {
                showingImagePicker = true
            }) {
                Text("Загрузить файл")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                    .foregroundColor(.white) // Белый цвет текста
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            TextField("URL видео", text: $newVideoURL)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Редактировать задания")
                    .font(.headline)
                    .foregroundColor(.white) // Белый цвет текста
                
                
                ForEach(newAssignments.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Название задания", text: $newAssignments[index].title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)
                        
                        Picker("Тип задания", selection: $newAssignments[index].type) {
                            Text("Множественный выбор").tag(AssignmentType.multipleChoice)
                            Text("Текстовый ответ").tag(AssignmentType.textAnswer)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 4)
                        
                        if newAssignments[index].type == .multipleChoice {
                            ForEach(newAssignments[index].choices.indices, id: \.self) { choiceIndex in
                                HStack {
                                    TextField("Вариант \(choiceIndex + 1)", text: $newAssignments[index].choices[choiceIndex])
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Toggle(isOn: Binding<Bool>(
                                        get: {
                                            newAssignments[index].choices[choiceIndex] == newAssignments[index].correctAnswer
                                        },
                                        set: { newValue in
                                            if newValue {
                                                newAssignments[index].correctAnswer = newAssignments[index].choices[choiceIndex]
                                            }
                                        }
                                    )) {
                                        Text("Правильный")
                                    }
                                    
                                    Button(action: {
                                        newAssignments[index].choices.remove(at: choiceIndex)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            Button(action: {
                                newAssignments[index].choices.append("")
                            }) {
                                Text("Добавить вариант ответа")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white) // Белый цвет текста
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                Button(action: addNewAssignment) {
                    Text("Добавить задание")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white) // Белый цвет текста
                        .cornerRadius(10)
                }
            }
            
            HStack {
                Button(action: {
                    viewModel.updateLesson(content: newContent, videoURL: newVideoURL, assignments: newAssignments)
                    isEditing = false
                }) {
                    Text("Сохранить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white) // Белый цвет текста
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
                        .foregroundColor(.white) // Белый цвет текста
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
        }
    }
    
    private var lessonDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.lesson.content)
                .font(.body)
                .foregroundColor(.white) // Белый цвет текста
            
            if let errorMessage = viewModel.errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .foregroundColor(.red)
            }

            if let videoURL = viewModel.lesson.videoURL, !videoURL.isEmpty {
                WebView(url: URL(string: videoURL)!)
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            
            Divider()
            
            Text("Задания и тесты")
                .font(.headline)
                .foregroundColor(.white) // Белый цвет текста
                .padding(.bottom, 8)
            
            if !viewModel.lesson.assignments.isEmpty {
                ForEach(viewModel.lesson.assignments, id: \.id) { assignment in
                    AssignmentView(assignment: assignment)
                }
            } else {
                Text("Нет доступных заданий")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                newContent = viewModel.lesson.content
                newVideoURL = viewModel.lesson.videoURL ?? ""
                newAssignments = viewModel.lesson.assignments
                isEditing = true
            }) {
                Text("Редактировать")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white) // Белый цвет текста
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            
            Button(action: {
                print("Кнопка 'Удалить урок' нажата") // Для отладки
                viewModel.deleteLesson()
            }) {
                Text("Удалить урок")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white) // Белый цвет текста
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
    }

    private func addNewAssignment() {
        newAssignments.append(Assignment(id: UUID().uuidString, title: "", type: .multipleChoice, choices: [""], correctAnswer: ""))
    }
}

// WebView для показа видео с YouTube
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
