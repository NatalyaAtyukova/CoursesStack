//
//  UserCoursesView.swift
//  CoursesStack
//
//  Created by Наталья Атюкова on 18.09.2024.
//

import SwiftUI

struct UserCoursesView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Courses Catalog")
                .font(.largeTitle)
                .padding()
            
            List {
                Text("Course 1")
                Text("Course 2")
            }
        }
        .padding()
    }
}
