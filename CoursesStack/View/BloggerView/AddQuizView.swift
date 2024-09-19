import SwiftUI

struct AddQuizView: View {
    @ObservedObject var viewModel: CourseViewModel
    @State private var quizTitle = ""
    
    var body: some View {
        VStack {
            TextField("Название теста", text: $quizTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.addQuiz(title: quizTitle)
            }) {
                Text("Добавить тест")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Добавление теста")
    }
}
