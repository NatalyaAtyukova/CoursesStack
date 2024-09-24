import SwiftUI

struct AssignmentView: View {
    var assignment: Assignment
    
    @State private var selectedChoice: String = ""
    @State private var userAnswer: String = ""
    @State private var isAnswerCorrect: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(assignment.title)
                .font(.headline)
            
            // Проверяем тип задания
            if assignment.type == .multipleChoice {
                // Задание с выбором правильного ответа
                ForEach(assignment.choices, id: \.self) { choice in
                    HStack {
                        Button(action: {
                            selectedChoice = choice
                            checkAnswer(choice: choice)
                        }) {
                            HStack {
                                Image(systemName: selectedChoice == choice ? "checkmark.circle.fill" : "circle")
                                Text(choice)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            } else if assignment.type == .textAnswer {
                // Задание с текстовым ответом
                TextField("Ваш ответ", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top, 8)
                
                Button(action: {
                    checkAnswer(choice: userAnswer)
                }) {
                    Text("Проверить ответ")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if isAnswerCorrect {
                Text("Правильный ответ!")
                    .foregroundColor(.green)
                    .padding(.top, 10)
            } else if !isAnswerCorrect && !selectedChoice.isEmpty {
                Text("Неправильный ответ!")
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // Функция для проверки ответа
    private func checkAnswer(choice: String) {
        // Проверяем введённый или выбранный ответ с правильным ответом
        if choice == assignment.correctAnswer {
            isAnswerCorrect = true
        } else {
            isAnswerCorrect = false
        }
    }
}
