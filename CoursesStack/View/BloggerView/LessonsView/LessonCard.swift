import SwiftUI

struct LessonCard: View {
    var lesson: Lesson

    var body: some View {
        HStack {
            Image(systemName: "book")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
