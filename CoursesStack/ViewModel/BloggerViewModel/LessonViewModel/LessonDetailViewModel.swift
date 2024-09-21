import SwiftUI
import Combine

class LessonDetailViewModel: ObservableObject {
    @Published var lesson: Lesson
    @Published var errorMessage: String?
    @Published var isDeleted = false

    private var cancellables = Set<AnyCancellable>()
    private let courseService: CourseService // Предположим, что существует сервис для работы с курсами
    
    init(lesson: Lesson, courseService: CourseService) {
        self.lesson = lesson
        self.courseService = courseService
    }
    
    // Обновление урока
    func updateLesson(content: String, videoURL: String?) {
        // Обновляем локальные данные
        lesson.content = content
        lesson.videoURL = videoURL

        // Обновляем на сервере (например, через Firebase или другой сервис)
        courseService.updateLesson(lesson)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { _ in
                // Успешно обновлено
            }
            .store(in: &cancellables)
    }
    
    // Удаление урока
    func deleteLesson() {
        courseService.deleteLesson(lesson.id)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    self.isDeleted = true
                }
            } receiveValue: { _ in
                // Урок успешно удален
            }
            .store(in: &cancellables)
    }
}
