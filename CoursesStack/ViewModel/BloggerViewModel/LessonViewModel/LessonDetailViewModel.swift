import SwiftUI
import Combine

class LessonDetailViewModel: ObservableObject {
    @Published var lesson: Lesson
    @Published var errorMessage: String?
    @Published var isDeleted = false
    @Published var isUpdated = false // Для отслеживания успешного обновления
    
    private var cancellables = Set<AnyCancellable>()
    private let courseService: CourseService // Сервис для работы с курсами
    
    init(lesson: Lesson, courseService: CourseService) {
        self.lesson = lesson
        self.courseService = courseService
    }
    
    // Обновление урока, включая задания
    func updateLesson(content: String, videoURL: String?, assignments: [Assignment]) {
        // Обновляем локальные данные
        lesson.content = content
        lesson.videoURL = videoURL
        lesson.assignments = assignments
        
        // Обновляем на сервере
        courseService.updateLesson(lesson)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    self.isUpdated = true // Уведомляем об успешном обновлении
                }
            } receiveValue: { _ in
                // Успешно обновлено
            }
            .store(in: &cancellables)
    }
    
    // Удаление урока
    func deleteLesson() {
        print("Начало удаления урока с id: \(lesson.id)") // Для отладки
        courseService.deleteLesson(lesson.id)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Ошибка удаления урока: \(error.localizedDescription)") // Для отладки
                case .finished:
                    self.isDeleted = true
                    print("Урок успешно удален") // Для отладки
                }
            } receiveValue: { _ in
                // Успешное удаление
            }
            .store(in: &cancellables)
    }
}
