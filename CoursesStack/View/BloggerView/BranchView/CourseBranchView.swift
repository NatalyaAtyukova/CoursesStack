import SwiftUI

struct CourseBranchView: View {
    let isCompleted: Bool
    
    var body: some View {
        VStack {
            // Верхняя линия
            Rectangle()
                .fill(Color.gray)
                .frame(width: 2, height: 20)
            
            // Круг, указывающий на состояние ветки
            ZStack {
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            
            // Нижняя линия
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 2, height: 20)
        }
    }
}
