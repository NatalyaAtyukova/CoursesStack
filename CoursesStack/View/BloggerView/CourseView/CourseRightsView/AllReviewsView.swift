import SwiftUI

struct AllReviewsView: View {
    var course: Course
    var reviews: [Review]

    var body: some View {
        VStack {
            Text(String(format: NSLocalizedString("all_reviews_for_course", comment: ""), course.title)) // Локализованный заголовок с названием курса
                .font(.title)
                .foregroundColor(.white)
                .padding()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(reviews) { review in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: NSLocalizedString("user_label", comment: ""), review.userID)) // Локализованная метка пользователя
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            HStack {
                                Text(NSLocalizedString("rating_label", comment: "")) // Локализованная метка рейтинга
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
        .navigationTitle(NSLocalizedString("all_reviews_title", comment: "")) // Локализованный заголовок экрана
        .navigationBarTitleDisplayMode(.inline)
    }
}
