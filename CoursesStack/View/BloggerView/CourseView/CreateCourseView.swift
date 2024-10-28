import SwiftUI
import PhotosUI
import FirebaseStorage

struct CreateCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BloggerDashboardViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedCurrency = "USD"
    @State private var coverImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var coverImageURL = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                TextField(NSLocalizedString("course_title_placeholder", comment: ""), text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .foregroundColor(.black)
                
                TextEditor(text: $description)
                    .frame(height: 250)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1))
                    .padding(.horizontal)
                
                TextField(NSLocalizedString("course_price_placeholder", comment: ""), text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    
                // Выбор валюты
                Picker(NSLocalizedString("currency_picker", comment: ""), selection: $selectedCurrency) {
                    Text("USD").tag("USD")
                    Text("EUR").tag("EUR")
                    Text("RUB").tag("RUB")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    if let coverImage = coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(8)
                            .padding(.horizontal)
                    } else {
                        Text(NSLocalizedString("select_cover_image", comment: "")) // Локализованный текст "Выберите изображение обложки"
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            
            if isUploading {
                ProgressView(value: uploadProgress)
                    .padding()
            }
            
            Button(action: createCourse) {
                Text(NSLocalizedString("create_course_button", comment: "")) // Локализованный текст "Создать курс"
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 235/255, green: 64/255, blue: 52/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(red: 44/255, green: 44/255, blue: 46/255).edgesIgnoringSafeArea(.all))
        .navigationTitle(NSLocalizedString("course_creation_title", comment: "")) // Локализованный заголовок "Создание курса"
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $coverImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(NSLocalizedString("error_title", comment: "")),
                  message: Text(alertMessage),
                  dismissButton: .default(Text(NSLocalizedString("ok_button", comment: "")))) // Локализованная кнопка "ОК"
        }
    }
    
    func createCourse() {
        guard !title.isEmpty, !description.isEmpty, !price.isEmpty else {
            alertMessage = NSLocalizedString("fill_all_fields_error", comment: "") // Локализованное сообщение "Заполните все поля"
            showAlert = true
            return
        }
        
        guard let image = coverImage, let coursePrice = Double(price) else {
            alertMessage = NSLocalizedString("choose_image_and_valid_price_error", comment: "") // Локализованное сообщение "Пожалуйста, выберите изображение обложки и укажите корректную цену"
            showAlert = true
            return
        }
        
        isUploading = true
        uploadImage(image) { url in
            if let url = url {
                viewModel.createCourse(
                    title: title,
                    description: description,
                    price: coursePrice,
                    currency: selectedCurrency,
                    coverImageURL: url.absoluteString
                )
                presentationMode.wrappedValue.dismiss()
            } else {
                alertMessage = NSLocalizedString("upload_image_error", comment: "") // Локализованное сообщение "Не удалось загрузить изображение. Пожалуйста, попробуйте ещё раз"
                showAlert = true
            }
            isUploading = false
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("course_images/\(UUID().uuidString).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard metadata != nil else {
                    print("Не удалось загрузить изображение: метаданные отсутствуют")
                    completion(nil)
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Ошибка получения URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        print("URL загруженного изображения: \(url?.absoluteString ?? "Нет URL")")
                        completion(url)
                    }
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                uploadProgress = Double(snapshot.progress?.fractionCompleted ?? 0)
            }
        } else {
            print("Ошибка создания данных изображения")
            completion(nil)
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .photoLibrary
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let selectedImage = info[.originalImage] as? UIImage {
                    parent.image = selectedImage
                }
                picker.dismiss(animated: true)
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
