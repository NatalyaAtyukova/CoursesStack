import SwiftUI

struct CoursePurchaseView: View {
    @ObservedObject var viewModel: CoursePurchaseViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                if let imageURL = URL(string: viewModel.course.coverImageURL) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .clipped()
                                .shadow(radius: 5)
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(viewModel.course.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                Text(viewModel.course.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                
                Text(String(format: NSLocalizedString("price_label", comment: "Label for course price"), viewModel.course.price, viewModel.course.currency.symbol))
                    .font(.title2)
                    .foregroundColor(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .padding(.top, 8)
                
                Button(action: {
                    viewModel.purchaseCourse()
                }) {
                    Text(String(format: NSLocalizedString("purchase_course_button", comment: "Button text for purchasing course"), viewModel.course.price, viewModel.course.currency.symbol))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding(.top, 16)
                .disabled(viewModel.isPurchased)
                
                if viewModel.isPurchased {
                    Text(NSLocalizedString("course_already_purchased", comment: "Message indicating the course is already purchased"))
                        .foregroundColor(.green)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .background(Color(red: 44/255, green: 44/255, blue: 46/255))
    }
}
