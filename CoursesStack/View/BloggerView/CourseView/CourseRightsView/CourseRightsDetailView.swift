import SwiftUI

struct CourseRightsDetailView: View {
    var course: Course
    @ObservedObject var viewModel: CourseRightsDetailViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Раздел отзывов
                    if !viewModel.reviews.isEmpty {
                        Text("Отзывы")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(.top, 10)

                        ForEach(viewModel.reviews) { review in
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
                    } else {
                        Text("Нет отзывов.")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    }

                    // Раздел пользователей, купивших курс
                    if !viewModel.purchasedUsers.isEmpty {
                        Text("Купившие пользователи")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(.top, 20)

                        ForEach(viewModel.purchasedUsers) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.userName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("ID: \(user.id)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 70/255, green: 70/255, blue: 72/255))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                        }
                    } else {
                        Text("Нет купивших пользователей.")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            viewModel.fetchReviews()
            viewModel.fetchPurchasedUsers()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all))
        .navigationTitle("Детали курса: \(course.title)")
    }
}
