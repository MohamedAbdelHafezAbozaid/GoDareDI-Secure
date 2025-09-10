//
//  User.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - User Models
public struct User: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let email: String
    public let avatar: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        name: String,
        email: String,
        avatar: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct UserProfile: Codable, Sendable {
    public let user: User
    public let preferences: UserPreferences
    public let statistics: UserStatistics
    
    public init(user: User, preferences: UserPreferences, statistics: UserStatistics) {
        self.user = user
        self.preferences = preferences
        self.statistics = statistics
    }
}

public struct UserPreferences: Codable, Sendable {
    public let theme: String
    public let language: String
    public let notifications: Bool
    
    public init(theme: String = "light", language: String = "en", notifications: Bool = true) {
        self.theme = theme
        self.language = language
        self.notifications = notifications
    }
}

public struct UserStatistics: Codable, Sendable {
    public let totalPosts: Int
    public let totalLikes: Int
    public let joinDate: Date
    
    public init(totalPosts: Int = 0, totalLikes: Int = 0, joinDate: Date = Date()) {
        self.totalPosts = totalPosts
        self.totalLikes = totalLikes
        self.joinDate = joinDate
    }
}
