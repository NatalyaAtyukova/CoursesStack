import SwiftUI

struct BranchCard: View {
    var branch: CourseBranch
    var isCompleted: Bool
    var description: String  // Добавляем описание курса

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Вид состояния ветки с кругом и линиями
            CourseBranchView(isCompleted: isCompleted)

            // Контент с информацией о ветке, описанием и уроками
            VStack(alignment: .leading, spacing: 10) {
                Text(branch.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                // Описание курса
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)  // Ограничение по количеству строк, можно настроить

                ForEach(branch.lessons) { lesson in
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                        Text(lesson.title)
                            .font(.body)
                        Spacer()
                    }
                }
                
                Divider()
            }
            .padding(.leading, 10)
        }
        .padding(.horizontal)
    }
}

