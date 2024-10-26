import SwiftUI

struct CourseRightsDetailView: View {
    var course: Course
    @ObservedObject var viewModel: CourseRightsDetailViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Статистика купивших пользователей
                    Text("Купившие пользователи")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.top, 20)
                    
                    Text("Количество купивших пользователей: \(course.purchasedBy.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 70/255, green: 70/255, blue: 72/255))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)

                    // Раздел последних отзывов
                    if !viewModel.reviews.isEmpty {
                        Text("Отзывы")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(.top, 10)

                        ForEach(viewModel.reviews.prefix(5)) { review in
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

                        // Навигация ко всем отзывам
                        NavigationLink(destination: AllReviewsView(course: course, reviews: viewModel.reviews)) {
                            Text("Посмотреть все отзывы")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("Нет отзывов.")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            viewModel.fetchReviews()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all))
        .navigationTitle("Детали курса: \(course.title)")
    }
}
