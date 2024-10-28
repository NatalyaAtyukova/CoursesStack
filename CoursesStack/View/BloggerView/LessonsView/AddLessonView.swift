import SwiftUI
import UniformTypeIdentifiers

struct AddLessonView: View {
    var branchID: String
    var branchName: String
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var lessonTitle = ""
    @State private var lessonContent = ""
    @State private var videoURL = ""
    @State private var assignments = [Assignment]()
    @State private var downloadableFiles = [DownloadableFile]()
    @State private var showAlert = false
    @State private var showDocumentPicker = false
    @State private var selectedFileURL: URL?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Отображение имени ветки
                Text(String(format: NSLocalizedString("add_lesson_to_branch", comment: ""), branchName)) // Локализованное сообщение для заголовка
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(.white)
                
                // Поле для названия урока
                TextField(NSLocalizedString("lesson_title_placeholder", comment: ""), text: $lessonTitle)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                
                // Большое поле для содержания урока
                TextEditor(text: $lessonContent)
                    .frame(height: 200)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                
                // Поле для ссылки на видео (опционально)
                TextField(NSLocalizedString("video_url_placeholder", comment: ""), text: $videoURL)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                
                // Кнопка для выбора файла через DocumentPicker
                Button(action: {
                    showDocumentPicker.toggle()
                }) {
                    Text(NSLocalizedString("add_file_button", comment: "")) // Локализованный текст для кнопки "Добавить файл"
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(fileURL: $selectedFileURL)
                }
                
                // Раздел для добавления заданий
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("assignments_title", comment: "")) // Локализованный заголовок "Задания"
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(assignments.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            let assignment = assignments[index]
                            
                            TextField(NSLocalizedString("assignment_title_placeholder", comment: ""), text: $assignments[index].title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 4)
                                .foregroundColor(.black)
                            
                            Picker(NSLocalizedString("assignment_type", comment: ""), selection: $assignments[index].type) {
                                Text(NSLocalizedString("multiple_choice", comment: "")).tag(AssignmentType.multipleChoice)
                                Text(NSLocalizedString("text_answer", comment: "")).tag(AssignmentType.textAnswer)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 4)
                            
                            if assignment.type == .multipleChoice {
                                // Варианты ответов
                                VStack(alignment: .leading) {
                                    ForEach(assignment.choices.indices, id: \.self) { choiceIndex in
                                        HStack {
                                            TextField(String(format: NSLocalizedString("choice_placeholder", comment: ""), choiceIndex + 1), text: $assignments[index].choices[choiceIndex])
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .foregroundColor(.black)
                                            
                                            Toggle(isOn: Binding<Bool>(
                                                get: {
                                                    assignments[index].choices[choiceIndex] == assignments[index].correctAnswer
                                                },
                                                set: { newValue in
                                                    if newValue {
                                                        assignments[index].correctAnswer = assignments[index].choices[choiceIndex]
                                                    } else {
                                                        assignments[index].correctAnswer = ""
                                                    }
                                                }
                                            )) {
                                                Text(NSLocalizedString("correct_answer_label", comment: "")) // Локализованный текст "Правильный"
                                            }
                                            .tint(Color(red: 235/255, green: 64/255, blue: 52/255))
                                            
                                            Button(action: {
                                                assignments[index].choices.remove(at: choiceIndex)
                                            }) {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                                            }
                                        }
                                    }
                                    
                                    Button(action: {
                                        assignments[index].choices.append("")
                                    }) {
                                        Text(NSLocalizedString("add_choice_button", comment: "")) // Локализованная кнопка "Добавить вариант ответа"
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            } else {
                                TextField(NSLocalizedString("correct_text_answer_placeholder", comment: ""), text: $assignments[index].correctAnswer)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                assignments.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Button(action: addAssignment) {
                        Text(NSLocalizedString("add_assignment_button", comment: "")) // Локализованная кнопка "Добавить задание"
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Кнопка для добавления урока
                Button(action: {
                    if validateLessonData() {
                        viewModel.addLesson(
                            to: branchID,
                            title: lessonTitle,
                            content: lessonContent,
                            videoURL: videoURL.isEmpty ? nil : videoURL,
                            assignments: assignments,
                            downloadableFiles: downloadableFiles
                        )
                        clearFields()
                        showAlert = true
                    }
                }) {
                    Text(NSLocalizedString("add_lesson_button", comment: "")) // Локализованная кнопка "Добавить урок"
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(NSLocalizedString("lesson_added_alert_title", comment: "")), // Локализованное сообщение "Урок добавлен!"
                        message: Text(NSLocalizedString("lesson_added_alert_message", comment: "")), // Локализованное сообщение об успешном добавлении урока
                        dismissButton: .default(Text(NSLocalizedString("ok_button", comment: ""))) // Локализованная кнопка "OK"
                    )
                }
            }
                .padding()
                .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для всего экрана
            }
        }
        
        private func clearFields() {
            lessonTitle = ""
            lessonContent = ""
            videoURL = ""
            assignments.removeAll()
            downloadableFiles.removeAll()
        }
        
        private func addAssignment() {
            assignments.append(Assignment(id: UUID().uuidString, title: "", type: .multipleChoice, choices: [""], correctAnswer: ""))
        }
        
        private func validateLessonData() -> Bool {
            return !lessonTitle.isEmpty && !lessonContent.isEmpty
        }
    }
    
    // Новый компонент для выбора файлов
    struct DocumentPicker: UIViewControllerRepresentable {
        @Binding var fileURL: URL?
        
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIDocumentPickerDelegate {
            let parent: DocumentPicker
            
            init(_ parent: DocumentPicker) {
                self.parent = parent
            }
            
            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                parent.fileURL = urls.first
            }
            
            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                parent.fileURL = nil
            }
        }
    }
    
