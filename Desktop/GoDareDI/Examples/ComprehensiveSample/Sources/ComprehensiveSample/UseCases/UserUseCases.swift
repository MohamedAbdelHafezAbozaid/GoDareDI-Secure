//
//  UserUseCases.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - User Use Cases Protocols
public protocol GetAllUsersUseCaseProtocol: Sendable {
    func execute() async throws -> [User]
}

public protocol GetUserUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> User
}

public protocol GetUserProfileUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> UserProfile
}

public protocol UpdateUserPreferencesUseCaseProtocol: Sendable {
    func execute(_ preferences: UserPreferences) async throws -> UserPreferences
}

public protocol GetUserStatisticsUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> UserStatistics
}

public protocol UploadAvatarUseCaseProtocol: Sendable {
    func execute(data: Data) async throws -> String
}

// MARK: - Use Case Implementations
public final class GetAllUsersUseCase: GetAllUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [User] {
        print("🎯 Executing GetAllUsersUseCase")
        let users = try await repository.getAllUsers()
        print("✅ GetAllUsersUseCase completed with \(users.count) users")
        return users
    }
}

public final class GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(id: String) async throws -> User {
        print("🎯 Executing GetUserUseCase for ID: \(id)")
        let user = try await repository.getUser(id: id)
        print("✅ GetUserUseCase completed for user: \(user.name)")
        return user
    }
}

public final class GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(id: String) async throws -> UserProfile {
        print("🎯 Executing GetUserProfileUseCase for ID: \(id)")
        let profile = try await repository.getUserProfile(id: id)
        print("✅ GetUserProfileUseCase completed for user: \(profile.user.name)")
        return profile
    }
}

public final class UpdateUserPreferencesUseCase: UpdateUserPreferencesUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(_ preferences: UserPreferences) async throws -> UserPreferences {
        print("🎯 Executing UpdateUserPreferencesUseCase")
        let updatedPreferences = try await repository.updateUserPreferences(preferences)
        print("✅ UpdateUserPreferencesUseCase completed")
        return updatedPreferences
    }
}

public final class GetUserStatisticsUseCase: GetUserStatisticsUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(id: String) async throws -> UserStatistics {
        print("🎯 Executing GetUserStatisticsUseCase for ID: \(id)")
        let statistics = try await repository.getUserStatistics(id: id)
        print("✅ GetUserStatisticsUseCase completed: \(statistics.totalPosts) posts, \(statistics.totalLikes) likes")
        return statistics
    }
}

public final class UploadAvatarUseCase: UploadAvatarUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(data: Data) async throws -> String {
        print("🎯 Executing UploadAvatarUseCase with \(data.count) bytes")
        let avatarURL = try await repository.uploadAvatar(data: data)
        print("✅ UploadAvatarUseCase completed: \(avatarURL)")
        return avatarURL
    }
}
