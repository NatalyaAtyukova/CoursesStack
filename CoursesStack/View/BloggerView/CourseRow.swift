import SwiftUI

struct CourseRow: View {
    var course: Course
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: course.coverImageURL)) { image in
                image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
            
            Text(course.title)
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}

