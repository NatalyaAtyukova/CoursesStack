import SwiftUI

struct CourseRightsDetailView: View {
    var course: Course
    @ObservedObject var viewModel: CourseRightsDetailViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Статистика купивших пользователей
                    Text(NSLocalizedString("purchased_users_title", comment: "")) // Локализованный заголовок "Купившие пользователи"
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.top, 20)
                    
                    Text(String(format: NSLocalizedString("purchased_user_count", comment: ""), course.purchasedBy.count)) // Локализованный текст с количеством купивших пользователей
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 70/255, green: 70/255, blue: 72/255))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)

                    // Раздел последних отзывов
                    if !viewModel.reviews.isEmpty {
                        Text(NSLocalizedString("reviews_title", comment: "")) // Локализованный заголовок "Отзывы"
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(.top, 10)

                        ForEach(viewModel.reviews.prefix(5)) { review in
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

                        // Навигация ко всем отзывам
                        NavigationLink(destination: AllReviewsView(course: course, reviews: viewModel.reviews)) {
                            Text(NSLocalizedString("view_all_reviews", comment: "")) // Локализованный текст "Посмотреть все отзывы"
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    } else {
                        Text(NSLocalizedString("no_reviews", comment: "")) // Локализованный текст "Нет отзывов"
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
        .navigationTitle(String(format: NSLocalizedString("course_details_title", comment: ""), course.title)) // Локализованный заголовок экрана
    }
}
