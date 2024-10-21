import SwiftUI

struct ReviewSection: View {
    @ObservedObject var viewModel: MyCourseDetailViewModel
    @State private var reviewText: String = ""
    @State private var rating: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Форма для оставления отзыва
            Text("Оставить отзыв")
                .font(.headline)
                .padding(.top, 8)

            TextEditor(text: $reviewText)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding(.horizontal)

            // Используем звезды для отображения оценки
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.horizontal)

            Button(action: {
                viewModel.addReview(content: reviewText, rating: rating)
                // Очищаем форму после отправки
                reviewText = ""
                rating = 5
            }) {
                Text("Отправить отзыв")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)

            // Отображение списка отзывов
            if !viewModel.reviews.isEmpty {
                Text("Отзывы")
                    .font(.headline)
                    .padding(.top, 8)

                ForEach(viewModel.reviews) { review in
                    ReviewCard(review: review)  // Используем ReviewCard для каждого отзыва
                }
            } else {
                Text("Отзывов пока нет")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
