import SwiftUI
import PhotosUI
import FirebaseStorage

struct CreateCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BloggerDashboardViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var coverImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var coverImageURL = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                TextField("Название курса", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextEditor(text: $description)
                    .frame(height: 200)
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1))
                
                TextField("Цена курса", text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    if let coverImage = coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        Text("Выберите изображение обложки")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            
            if isUploading {
                ProgressView(value: uploadProgress)
                    .padding()
            }
            
            Button(action: createCourse) {
                Text("Создать курс")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(white: 0.95).edgesIgnoringSafeArea(.all))
        .navigationTitle("Создание курса")
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $coverImage)
        }
    }
    
    func createCourse() {
        guard let image = coverImage, let coursePrice = Double(price) else {
            // Показываем ошибку, если изображение не выбрано или цена некорректна
            return
        }
        
        isUploading = true
        uploadImage(image) { url in
            if let url = url {
                viewModel.createCourse(title: title, description: description, price: coursePrice, coverImageURL: url.absoluteString)
                presentationMode.wrappedValue.dismiss()
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
