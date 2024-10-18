import SwiftUI

struct MyLessonDetailView: View {
    @ObservedObject var viewModel: LessonDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок урока
                Text(viewModel.lesson.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // Содержимое урока
                Text(viewModel.lesson.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Воспроизведение видео, если есть URL
                if let videoURL = viewModel.lesson.videoURL, !videoURL.isEmpty {
                    WebView(url: URL(string: videoURL)!)
                        .frame(height: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 20)
                } else {
                    Text("Видео не найдено")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Divider()
                
                // Секция для заданий
                Text("Задания и тесты")
                    .font(.headline)
                    .foregroundColor(.white)
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
                
                // Секция для файлов
                if !viewModel.lesson.downloadableFiles.isEmpty {
                    Text("Файлы для скачивания")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    ForEach(viewModel.lesson.downloadableFiles) { file in
                        Button(action: {
                            downloadFile(file)
                        }) {
                            Text(file.fileName)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255)) // Темный фон для экрана
    }
    
    // Логика для загрузки файла
    func downloadFile(_ file: DownloadableFile) {
        if let url = URL(string: file.fileURL) {
            UIApplication.shared.open(url)
        }
    }
}
