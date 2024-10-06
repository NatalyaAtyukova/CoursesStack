//
//  Database.swift
//  CoursesStack
//
//  Created by Наталья Атюкова on 18.09.2024.
//

import Foundation
import Firebase

// Перечисление для валют
enum Currency: String, Codable, CaseIterable, Identifiable {
    case ruble = "RUB"
    case euro = "EUR"
    case dollar = "USD"
    
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .ruble:
            return "₽"
        case .euro:
            return "€"
        case .dollar:
            return "$"
        }
    }
}

struct UserModel {
    var id: String
    var email: String
    var role: String
    var authorName: String? // Имя автора, опциональное для блогеров
}

struct Course: Identifiable, Decodable {
    var id: String
    var title: String
    var description: String
    var price: Double
    var currency: Currency
    var coverImageURL: String
    var authorID: String?  // Поле опциональное
    var authorName: String?  // Поле опциональное
    var branches: [CourseBranch]
    var reviews: [Review]
    var completedBranches: [String: Bool]
    var purchasedBy: [String]

    init(id: String, title: String, description: String, price: Double, currency: Currency, coverImageURL: String, authorID: String? = nil, authorName: String? = nil, branches: [CourseBranch], reviews: [Review], completedBranches: [String: Bool], purchasedBy: [String]) {
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
        self.completedBranches = completedBranches
        self.purchasedBy = purchasedBy
    }
}

//Blogger добавляет курсы

struct CourseBranch: Identifiable, Decodable {
    var id: String
    var title: String
    var description: String
    var lessons: [Lesson]
}

struct Lesson: Identifiable, Decodable {
    var id: String
    var title: String
    var content: String
    var videoURL: String?
    var assignments: [Assignment]
    var downloadableFiles: [DownloadableFile]
}

struct Assignment: Identifiable, Decodable {
    var id: String
    var title: String
    var type: AssignmentType
    var choices: [String]
    var correctAnswer: String
}

enum AssignmentType: String, Codable {
    case multipleChoice = "multipleChoice"
    case textAnswer = "textAnswer"
}

struct DownloadableFile: Identifiable, Decodable {
    var id: String
    var fileName: String
    var fileURL: String
}

struct Review: Identifiable, Decodable {
    var id: String
    var userID: String
    var content: String
    var rating: Int
}

struct CourseAccessRights: Identifiable, Decodable {
    var id: String { userID } // Например, используем userID как идентификатор
    var courseID: String
    var userID: String
    var canView: Bool
}
