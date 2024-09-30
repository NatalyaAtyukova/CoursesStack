import SwiftUI

struct LessonCard: View {
    var lesson: Lesson

    var body: some View {
        HStack {
            Image(systemName: "book")
                .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.content)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 60/255, green: 60/255, blue: 62/255))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
