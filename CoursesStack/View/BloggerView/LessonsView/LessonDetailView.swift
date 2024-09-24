import SwiftUI
import PhotosUI

struct LessonDetailView: View {
    @ObservedObject var viewModel: LessonDetailViewModel
    @State private var isEditing = false
    @State private var newContent = ""
    @State private var newVideoURL = ""
    @State private var selectedImage: UIImage? // Изображение, загруженное из галереи
    @State private var showingImagePicker = false // Флаг для показа ImagePicker
    @State private var newAssignments = [Assignment]() // Новые задания для редактирования

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
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
    }
    
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField("Текст урока", text: $newContent)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)

            // Кнопка для открытия галереи
            Button(action: {
                showingImagePicker = true
            }) {
                Text("Загрузить файл")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
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
            
            TextField("URL видео", text: $newVideoURL)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Редактировать задания")
                    .font(.headline)
                
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
                                    .foregroundColor(.white)
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
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            HStack {
                Button(action: {
                    // Сохраняем изменения урока
                    viewModel.updateLesson(content: newContent, videoURL: newVideoURL, assignments: newAssignments)
                    isEditing = false
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
    
    private var lessonDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.lesson.content)
                .font(.body)
            
            if let videoURL = viewModel.lesson.videoURL, !videoURL.isEmpty {
                Link("Видео урока", destination: URL(string: videoURL)!)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            Text("Задания и тесты")
                .font(.headline)
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
                newAssignments = viewModel.lesson.assignments // Загружаем текущие задания для редактирования
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
                viewModel.deleteLesson()
            }) {
                Text("Удалить урок")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
    }

    // Функция для добавления нового задания
    private func addNewAssignment() {
        newAssignments.append(Assignment(id: UUID().uuidString, title: "", type: .multipleChoice, choices: [""], correctAnswer: ""))
    }
}
