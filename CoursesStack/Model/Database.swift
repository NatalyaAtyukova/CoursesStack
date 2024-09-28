//
//  Database.swift
//  CoursesStack
//
//  Created by Наталья Атюкова on 18.09.2024.
//

import Foundation
import Firebase

struct UserModel {
    var id: String
    var email: String
    var role: String
    var authorName: String? // Имя автора, опциональное для блогеров
}

struct Course: Identifiable {
    var id: String
    var title: String
    var description: String
    var price: Double
    var currency: Currency
    var coverImageURL: String
    var authorID: String
    var authorName: String
    var branches: [CourseBranch]
    var reviews: [Review]
    var completedBranches: [String: Bool] = [:] // Добавляем completedBranches
    
    init(id: String, title: String, description: String, price: Double, currency: Currency, coverImageURL: String, authorID: String, authorName: String, branches: [CourseBranch], reviews: [Review], completedBranches: [String: Bool] = [:]) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.currency = currency
        self.coverImageURL = coverImageURL
        self.authorID = authorID
        self.authorName = authorName
        self.branches = branches
        self.reviews = reviews
        self.completedBranches = completedBranches // Инициализируем completedBranches
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
    var content: String // Текстовый контент
    var videoURL: String? // Ссылка на видео (например, YouTube)
    var assignments: [Assignment] // Задания и тесты
    var downloadableFiles: [DownloadableFile] // Файлы для скачивания
    
}

// Пример структуры задания
enum AssignmentType: String, CaseIterable {
    case multipleChoice = "multipleChoice"
    case textAnswer = "textAnswer"
}

struct Assignment: Identifiable {
    var id: String
    var title: String
    var type: AssignmentType // Тип задания
    var choices: [String] // Варианты ответов для multipleChoice
    var correctAnswer: String // Правильный ответ
}



// Пример структуры файла для скачивания
struct DownloadableFile: Identifiable {
    var id: String
    var fileName: String
    var fileURL: String
}

// Отзывы оставляет User

struct Review: Identifiable {
    var id: String
    var userID: String
    var content: String
    var rating: Int
}
