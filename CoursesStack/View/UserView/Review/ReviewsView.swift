import SwiftUI
import FirebaseAuth

struct ReviewsView: View {
    @ObservedObject var viewModel: MyCourseDetailViewModel
    @State private var reviewText: String = ""
    @State private var rating: Int = 5
    @State private var userHasLeftReview = false
    @State private var isEditingReview = false
    @State private var reviewToEdit: Review? = nil
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("reviews_title", comment: "")) // Локализованный заголовок "Отзывы"
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            if userHasLeftReview, let reviewToEdit = reviewToEdit {
                editReviewFormSection
            } else {
                reviewFormSection
            }

            Divider()
                .background(Color.gray)
                .padding(.horizontal)

            if !viewModel.reviews.isEmpty {
                ScrollView {
                    ForEach(viewModel.reviews) { review in
                        ReviewCard(review: review)
                            .contextMenu {
                                if review.userID == Auth.auth().currentUser?.uid {
                                    Button(NSLocalizedString("edit_review_title", comment: "")) {
                                        editReview(review: review)
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
            } else {
                Text(NSLocalizedString("no_reviews_message", comment: "")) // Локализованное сообщение "Отзывов пока нет"
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
                title: Text(NSLocalizedString("delete_review_button", comment: "")),
                message: Text(NSLocalizedString("delete_review_confirmation", comment: "")),
                primaryButton: .destructive(Text(NSLocalizedString("delete_button", comment: ""))) {
                    if let reviewToEdit = reviewToEdit {
                        deleteReview(review: reviewToEdit)
                    }
                },
                secondaryButton: .cancel(Text(NSLocalizedString("cancel_button", comment: "")))
            )
        }
        .edgesIgnoringSafeArea(.all)
    }

    private var reviewFormSection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("leave_review_title", comment: ""))
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
                    checkIfUserHasLeftReview()
                }
            }) {
                Text(NSLocalizedString("submit_review_button", comment: ""))
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

    private var editReviewFormSection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("edit_review_title", comment: ""))
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
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text(NSLocalizedString("delete_button", comment: ""))
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                Button(action: {
                    if let reviewToEdit = reviewToEdit {
                        viewModel.updateReview(review: reviewToEdit, newContent: reviewText, newRating: rating)
                        isEditingReview = false
                        checkIfUserHasLeftReview()
                    }
                }) {
                    Text(NSLocalizedString("save_changes_button", comment: ""))
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
                Text(NSLocalizedString("cancel_button", comment: ""))
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
