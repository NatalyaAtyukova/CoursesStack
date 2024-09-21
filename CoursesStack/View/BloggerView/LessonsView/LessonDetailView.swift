import SwiftUI
import Firebase

struct LessonDetailView: View {
    @ObservedObject var viewModel: LessonDetailViewModel // ViewModel для управления состоянием урока
    @State private var isEditing = false
    @State private var newContent = ""
    @State private var newVideoURL = ""
    
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
    }
    
    private var editingSection: some View {
        VStack(spacing: 16) {
            TextField("Текст урока", text: $newContent)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            TextField("URL видео", text: $newVideoURL)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 2)
            
            HStack {
                Button(action: {
                    viewModel.updateLesson(content: newContent, videoURL: newVideoURL)
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
                ForEach(viewModel.lesson.assignments) { assignment in
                    Text(assignment.question)
                        .font(.body)
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
}
