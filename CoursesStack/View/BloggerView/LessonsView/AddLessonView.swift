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
                Text("Добавление урока в ветку: \(branchName)")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    .foregroundColor(.white) // Белый цвет текста для заголовка
                
                // Поле для названия урока
                TextField("Название урока", text: $lessonTitle)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black) // Черный цвет текста
                
                // Большое поле для содержания урока
                TextEditor(text: $lessonContent)
                    .frame(height: 200)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black) // Черный цвет текста
                
                // Поле для ссылки на видео (опционально)
                TextField("Ссылка на видео (опционально)", text: $videoURL)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .foregroundColor(.black) // Черный цвет текста
                
                // Кнопка для выбора файла через DocumentPicker
                Button(action: {
                    showDocumentPicker.toggle()
                }) {
                    Text("Добавить файл")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                        .foregroundColor(.white) // Белый цвет текста
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(fileURL: $selectedFileURL)
                }

                // Раздел для добавления заданий
                VStack(alignment: .leading, spacing: 8) {
                    Text("Задания")
                        .font(.headline)
                        .foregroundColor(.white) // Белый цвет текста для заголовка

                    ForEach(assignments.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            let assignment = assignments[index]
                            
                            TextField("Название задания", text: $assignments[index].title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 4)
                                .foregroundColor(.black) // Черный цвет текста
                            
                            Picker("Тип задания", selection: $assignments[index].type) {
                                Text("Множественный выбор").tag(AssignmentType.multipleChoice)
                                Text("Текстовый ответ").tag(AssignmentType.textAnswer)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 4)

                            if assignment.type == .multipleChoice {
                                // Варианты ответов
                                VStack(alignment: .leading) {
                                    ForEach(assignment.choices.indices, id: \.self) { choiceIndex in
                                        HStack {
                                            TextField("Вариант \(choiceIndex + 1)", text: $assignments[index].choices[choiceIndex])
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .foregroundColor(.black) // Черный цвет текста
                                            
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
                                                Text("Правильный")
                                            }
                                            .tint(Color(red: 235/255, green: 64/255, blue: 52/255)) // Устанавливает цвет переключателя
                                            
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
                                        Text("Добавить вариант ответа")
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            } else {
                                TextField("Правильный текстовый ответ", text: $assignments[index].correctAnswer)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)
                                    .foregroundColor(.black) // Черный цвет текста
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
                        Text("Добавить задание")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                            .foregroundColor(.white) // Белый цвет текста
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
                    Text("Добавить урок")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255)) // Красная кнопка
                        .foregroundColor(.white) // Белый цвет текста
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Урок добавлен!"), message: Text("Ваш урок успешно добавлен."), dismissButton: .default(Text("OK")))
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
