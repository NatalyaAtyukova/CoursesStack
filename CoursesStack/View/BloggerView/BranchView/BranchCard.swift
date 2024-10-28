import SwiftUI

struct BranchCard: View {
    var branch: CourseBranch
    var isCompleted: Bool
    var description: String  // Добавляем описание курса
    var onLessonTap: (Lesson) -> Void // Замыкание для обработки нажатия на урок

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Вид состояния ветки с кругом и линиями
            CourseBranchView(isCompleted: isCompleted)

            // Контент с информацией о ветке, описанием и уроками
            VStack(alignment: .leading, spacing: 10) {
                Text(branch.title)
                    .font(.headline)
                    .foregroundColor(.white)

                // Описание курса
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)  // Ограничение по количеству строк, можно настроить
                    
                // Проверка на наличие уроков в ветке
                if branch.lessons.isEmpty {
                    Text(LocalizedStringKey("no_lessons")) // Локализованный текст "Нет уроков"
                        .font(.body)
                        .foregroundColor(.gray)
                } else {
                    ForEach(branch.lessons) { lesson in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                            Text(lesson.title)
                                .font(.body)
                            Spacer()
                        }
                        .onTapGesture {
                            onLessonTap(lesson) // Обработка нажатия на урок
                        }
                    }
                }
                
                Divider()
            }
            .padding(.leading, 10)
        }
        .padding(.horizontal)
    }
}
