import SwiftUI

struct AddLessonView: View {
    var branchID: String
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var lessonTitle = ""
    @State private var lessonContent = ""
    @State private var videoURL = ""
    @State private var assignments = [Assignment]()
    @State private var downloadableFiles = [DownloadableFile]()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Поле для названия урока
                TextField("Название урока", text: $lessonTitle)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                // Поле для содержания урока
                TextField("Содержание урока", text: $lessonContent)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                // Поле для ссылки на видео (опционально)
                TextField("Ссылка на видео (опционально)", text: $videoURL)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                // Раздел для добавления заданий
                VStack(alignment: .leading, spacing: 8) {
                    Text("Задания")
                        .font(.headline)

                    ForEach(assignments.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            // Проверка на допустимый диапазон индексов
                            if index < assignments.count {
                                TextField("Название задания", text: $assignments[index].title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)

                                Picker("Тип задания", selection: $assignments[index].type) {
                                    Text("Множественный выбор").tag(AssignmentType.multipleChoice)
                                    Text("Текстовый ответ").tag(AssignmentType.textAnswer)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 4)

                                if assignments[index].type == .multipleChoice {
                                    VStack(alignment: .leading) {
                                        // Доступ к choices без использования force unwrap
                                        ForEach(assignments[index].choices.indices, id: \.self) { choiceIndex in
                                            HStack {
                                                TextField("Вариант \(choiceIndex + 1)", text: $assignments[index].choices[choiceIndex])
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                                Button(action: {
                                                    assignments[index].choices.remove(at: choiceIndex)
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }

                                        Button(action: {
                                            assignments[index].choices.append("")
                                        }) {
                                            Text("Добавить вариант ответа")
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                } else {
                                    Text("Задание с текстовым ответом")
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 4)
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
                    }

                    Button(action: addAssignment) {
                        Text("Добавить задание")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                // Раздел для добавления файлов для скачивания
                VStack(alignment: .leading, spacing: 8) {
                    Text("Файлы для скачивания")
                        .font(.headline)

                    ForEach(downloadableFiles.indices, id: \.self) { index in
                        HStack {
                            if index < downloadableFiles.count {
                                TextField("Название файла", text: $downloadableFiles[index].fileName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 4)

                                Button(action: {
                                    downloadableFiles.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    Button(action: addDownloadableFile) {
                        Text("Добавить файл")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
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
                    }
                }) {
                    Text("Добавить урок")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    // Функция для добавления нового задания
    private func addAssignment() {
        assignments.append(Assignment(id: UUID().uuidString, title: "", type: .multipleChoice, choices: [""], correctAnswer: ""))
    }

    // Функция для добавления нового файла для скачивания
    private func addDownloadableFile() {
        downloadableFiles.append(DownloadableFile(id: UUID().uuidString, fileName: "", fileURL: ""))
    }
    
    // Проверка валидности данных урока
    private func validateLessonData() -> Bool {
        return !lessonTitle.isEmpty && !lessonContent.isEmpty
    }
}
