import SwiftUI
import FirebaseAuth

struct ReviewsView: View {
    @ObservedObject var viewModel: MyCourseDetailViewModel
    @State private var reviewText: String = ""
    @State private var rating: Int = 5
    @State private var userHasLeftReview = false  // Проверка, оставил ли пользователь отзыв
    @State private var isEditingReview = false    // Состояние для режима редактирования
    @State private var reviewToEdit: Review? = nil // Отзыв, который редактируется
    @State private var showDeleteConfirmation = false  // Состояние для отображения диалога удаления

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Отзывы")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            // Если пользователь уже оставил отзыв, показываем его для редактирования
            if userHasLeftReview, let reviewToEdit = reviewToEdit {
                editReviewFormSection
            } else {
                // Форма для оставления нового отзыва
                reviewFormSection
            }

            Divider()
                .background(Color.gray)
                .padding(.horizontal)

            // Отображение списка отзывов
            if !viewModel.reviews.isEmpty {
                ScrollView {
                    ForEach(viewModel.reviews) { review in
                        ReviewCard(review: review)
                            .contextMenu {
                                if review.userID == Auth.auth().currentUser?.uid {
                                    Button("Редактировать") {
                                        editReview(review: review)
                                    }
                                }
                            }
                            .padding(.bottom, 10)  // Отступы между отзывами
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Отзывов пока нет")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
        .onAppear {
            checkIfUserHasLeftReview()
        }
        .sheet(isPresented: $isEditingReview) {
            editReviewFormSection
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Удалить отзыв"),
                message: Text("Вы уверены, что хотите удалить этот отзыв?"),
                primaryButton: .destructive(Text("Удалить")) {
                    if let reviewToEdit = reviewToEdit {
                        deleteReview(review: reviewToEdit)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .edgesIgnoringSafeArea(.all)
    }

    // Форма для добавления нового отзыва
    private var reviewFormSection: some View {
        VStack(alignment: .leading) {
            Text("Оставить отзыв")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            ZStack {
                Color.white
                    .cornerRadius(10)
                    .frame(height: 150)
                    .shadow(radius: 5)

                TextEditor(text: $reviewText)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .font(.system(size: 24))
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.horizontal)

            Button(action: {
                if let userID = Auth.auth().currentUser?.uid {
                    viewModel.addReview(content: reviewText, rating: rating)
                    reviewText = ""
                    rating = 5
                    userHasLeftReview = true
                    checkIfUserHasLeftReview()  // Обновляем состояние после добавления отзыва
                } else {
                    print("Ошибка: пользователь не авторизован.")
                }
            }) {
                Text("Отправить отзыв")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
        }
    }

    // Форма для редактирования отзыва
    private var editReviewFormSection: some View {
        VStack(alignment: .leading) {
            Text("Редактировать отзыв")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            ZStack {
                Color.white
                    .cornerRadius(10)
                    .frame(height: 150)
                    .shadow(radius: 5)

                TextEditor(text: $reviewText)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .font(.system(size: 24))
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .padding(.horizontal)

            HStack {
                // Кнопка для удаления отзыва
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Удалить")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                // Кнопка для сохранения изменений
                Button(action: {
                    if let reviewToEdit = reviewToEdit {
                        viewModel.updateReview(review: reviewToEdit, newContent: reviewText, newRating: rating)
                        isEditingReview = false
                        checkIfUserHasLeftReview()  // Обновляем состояние после редактирования
                    }
                }) {
                    Text("Сохранить изменения")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal)

            Button(action: {
                isEditingReview = false
            }) {
                Text("Отменить")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    // Функции для редактирования и удаления отзыва
    private func editReview(review: Review) {
        reviewToEdit = review
        reviewText = review.content
        rating = review.rating
        isEditingReview = true
    }

    private func deleteReview(review: Review) {
        viewModel.deleteReview(review: review)
        isEditingReview = false
        checkIfUserHasLeftReview()  // Обновляем состояние после удаления отзыва
    }

    // Проверка, оставил ли пользователь отзыв и загрузка отзыва для редактирования
    private func checkIfUserHasLeftReview() {
        if let userID = Auth.auth().currentUser?.uid {
            if let userReview = viewModel.reviews.first(where: { $0.userID == userID }) {
                userHasLeftReview = true
                reviewToEdit = userReview
                reviewText = userReview.content
                rating = userReview.rating
            } else {
                userHasLeftReview = false
            }
        }
    }
}
