import SwiftUI

struct AllReviewsView: View {
    var course: Course
    var reviews: [Review]

    var body: some View {
        VStack {
            Text("Все отзывы для \(course.title)")
                .font(.title)
                .foregroundColor(.white)
                .padding()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(reviews) { review in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пользователь: \(review.userID)")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            HStack {
                                Text("Рейтинг:")
                                Text(String(repeating: "⭐️", count: review.rating))
                            }
                            .foregroundColor(.yellow)
                            
                            Text(review.content)
                                .foregroundColor(.white)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(red: 60/255, green: 60/255, blue: 62/255))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all))
        }
        .navigationTitle("Все отзывы")
        .navigationBarTitleDisplayMode(.inline) // Устанавливаем заголовок по центру
    }
}
