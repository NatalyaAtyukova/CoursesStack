import SwiftUI

struct AddLessonView: View {
    var branchID: String
    @ObservedObject var viewModel: CourseDetailViewModel
    @State private var lessonTitle = ""
    @State private var lessonContent = ""

    var body: some View {
        VStack {
            TextField("Название урока", text: $lessonTitle)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
            TextField("Содержание урока", text: $lessonContent)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

            Button(action: {
                viewModel.addLesson(to: branchID, title: lessonTitle, content: lessonContent)
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
