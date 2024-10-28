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
    
    @Environment(\.presentationMode) var presentationMode

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
        .navigationTitle(String(format: NSLocalizedString("lesson_detail_title", comment: ""), viewModel.lesson.title)) // Локализованный заголовок "Урок: ..."
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: viewModel.isDeleted) { isDeleted in
            if isDeleted {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField(NSLocalizedString("lesson_text_placeholder", comment: ""), text: $newContent) // Локализованный placeholder для текста урока
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .foregroundColor(.black) // Set text color to black
                .shadow(radius: 2)

            Button(action: {
                showingImagePicker = true
            }) {
                Text(NSLocalizedString("upload_file_button", comment: "")) // Локализованный текст "Загрузить файл"
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .foregroundColor(.white)
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
            
            TextField(NSLocalizedString("video_url_placeholder", comment: ""), text: $newVideoURL) // Локализованный placeholder для URL видео
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .foregroundColor(.black) // Set text color to black
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("edit_assignments_title", comment: "")) // Локализованный заголовок "Редактировать задания"
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(newAssignments.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(NSLocalizedString("assignment_title_placeholder", comment: ""), text: $newAssignments[index].title) // Локализованный placeholder для названия задания
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)
                            .foregroundColor(.black) // Set text color to black
                        
                        Picker(NSLocalizedString("assignment_type", comment: ""), selection: $newAssignments[index].type) { // Локализованный заголовок "Тип задания"
                            Text(NSLocalizedString("multiple_choice", comment: "")).tag(AssignmentType.multipleChoice)
                            Text(NSLocalizedString("text_answer", comment: "")).tag(AssignmentType.textAnswer)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 4)
                        
                        if newAssignments[index].type == .multipleChoice {
                            ForEach(newAssignments[index].choices.indices, id: \.self) { choiceIndex in
                                HStack {
                                    TextField(String(format: NSLocalizedString("choice_placeholder", comment: ""), choiceIndex + 1), text: $newAssignments[index].choices[choiceIndex]) // Локализованный placeholder "Вариант N"
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(.black) // Set text color to black
                                    
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
                                        Text(NSLocalizedString("correct_answer_label", comment: "")) // Локализованный текст "Правильный"
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
                                Text(NSLocalizedString("add_choice_button", comment: "")) // Локализованная кнопка "Добавить вариант ответа"
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                Button(action: addNewAssignment) {
                    Text(NSLocalizedString("add_assignment_button", comment: "")) // Локализованная кнопка "Добавить задание"
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            HStack {
                Button(action: {
                    viewModel.updateLesson(content: newContent, videoURL: newVideoURL, assignments: newAssignments)
                    isEditing = false
                }) {
                    Text(NSLocalizedString("save_button", comment: "")) // Локализованная кнопка "Сохранить"
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
                    Text(NSLocalizedString("cancel_button", comment: "")) // Локализованная кнопка "Отменить"
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
    
    private var lessonDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.lesson.content)
                .font(.body)
                .foregroundColor(.white) // Белый цвет текста
            
            if let errorMessage = viewModel.errorMessage {
                Text(String(format: NSLocalizedString("lesson_error_label", comment: ""), errorMessage)) // Локализованное сообщение об ошибке
                    .foregroundColor(.red)
            }

            if let videoURL = viewModel.lesson.videoURL, !videoURL.isEmpty {
                WebView(url: URL(string: videoURL)!)
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            
            Divider()
            
            Text(NSLocalizedString("lesson_assignments_title", comment: "")) // Локализованный заголовок "Задания и тесты"
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            if !viewModel.lesson.assignments.isEmpty {
                ForEach(viewModel.lesson.assignments, id: \.id) { assignment in
                    AssignmentView(assignment: assignment)
                }
            } else {
                Text(NSLocalizedString("no_assignments_available", comment: "")) // Локализованный текст "Нет доступных заданий"
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
                Text(NSLocalizedString("edit_button", comment: "")) // Локализованная кнопка "Редактировать"
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            
            Button(action: {
                viewModel.deleteLesson()
            }) {
                Text(NSLocalizedString("delete_lesson_button", comment: "")) // Локализованная кнопка "Удалить урок"
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
    }

    private func addNewAssignment() {
        newAssignments.append(Assignment(id: UUID().uuidString, title: "", type: .multipleChoice, choices: [""], correctAnswer: ""))
    }
}


