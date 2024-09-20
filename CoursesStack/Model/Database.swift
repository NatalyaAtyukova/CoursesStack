//
//  Database.swift
//  CoursesStack
//
//  Created by Наталья Атюкова on 18.09.2024.
//

import Foundation
import Firebase

struct UserModel: Identifiable {
    var id: String
    var email: String
    var role: String
}

struct Course: Identifiable {
    var id: String
    var title: String
    var description: String
    var price: Double
    var coverImageURL: String
    var authorID: String
    var branches: [CourseBranch]
    var quizzes: [Quiz]
    var reviews: [Review] // Добавляем отзывы в курс
    // Добавляем свойство для отслеживания завершенных веток
    var completedBranches: [String: Bool] = [:]
    
    init(id: String, title: String, description: String, price: Double, coverImageURL: String, authorID: String, branches: [CourseBranch], quizzes: [Quiz], reviews: [Review]) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.coverImageURL = coverImageURL
        self.authorID = authorID
        self.branches = branches
        self.quizzes = quizzes
        self.reviews = reviews
        
        // Инициализация completedBranches
        for branch in branches {
            self.completedBranches[branch.id] = false
        }
    }
}

//Blogger добавляет курсы

struct CourseBranch: Identifiable {
    var id: String
    var title: String
    var description: String
    var lessons: [Lesson]
}

struct Lesson: Identifiable {
    var id: String
    var title: String
    var content: String
}

struct Quiz: Identifiable {
    var id: String
    var title: String
    var questions: [Question]
}

struct Question: Identifiable {
    var id: String
    var questionText: String
    var answers: [String]
    var correctAnswerIndex: Int
}

// Отзывы оставляет User

struct Review: Identifiable {
    var id: String
    var userID: String
    var content: String
    var rating: Int
}
