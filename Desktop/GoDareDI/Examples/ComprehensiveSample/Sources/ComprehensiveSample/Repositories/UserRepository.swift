//
//  UserRepository.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - User Repository Protocol
public protocol UserRepositoryProtocol: Sendable {
    func getAllUsers() async throws -> [User]
    func getUser(id: String) async throws -> User
    func getUserProfile(id: String) async throws -> UserProfile
    func updateUserPreferences(_ preferences: UserPreferences) async throws -> UserPreferences
    func getUserStatistics(id: String) async throws -> UserStatistics
    func uploadAvatar(data: Data) async throws -> String
}

// MARK: - User Repository Implementation
public final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    public init(networkService: NetworkServiceProtocol, cacheService: CacheServiceProtocol) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    public func getAllUsers() async throws -> [User] {
        print("📋 Fetching all users from repository")
        
        // Try cache first
        if let cachedUsers: [User] = try await cacheService.get(key: "all_users") {
            print("✅ Found cached users")
            return cachedUsers
        }
        
        // Fetch from network
        let users: [User] = try await networkService.request(.users, responseType: [User].self)
        
        // Cache the result
        try await cacheService.set(key: "all_users", value: users, ttl: 300) // 5 minutes
        
        print("✅ Fetched \(users.count) users from network")
        return users
    }
    
    public func getUser(id: String) async throws -> User {
        print("👤 Fetching user with ID: \(id)")
        
        // Try cache first
        if let cachedUser: User = try await cacheService.get(key: "user_\(id)") {
            print("✅ Found cached user")
            return cachedUser
        }
        
        // For demo purposes, we'll get from the list and find the user
        let users = try await getAllUsers()
        guard let user = users.first(where: { $0.id == id }) else {
            throw RepositoryError.userNotFound
        }
        
        // Cache the result
        try await cacheService.set(key: "user_\(id)", value: user, ttl: 600) // 10 minutes
        
        print("✅ Found user: \(user.name)")
        return user
    }
    
    public func getUserProfile(id: String) async throws -> UserProfile {
        print("📊 Fetching user profile for ID: \(id)")
        
        // Try cache first
        if let cachedProfile: UserProfile = try await cacheService.get(key: "profile_\(id)") {
            print("✅ Found cached profile")
            return cachedProfile
        }
        
        // Fetch from network
        let profile: UserProfile = try await networkService.request(.userProfile, responseType: UserProfile.self)
        
        // Cache the result
        try await cacheService.set(key: "profile_\(id)", value: profile, ttl: 300) // 5 minutes
        
        print("✅ Fetched profile for user: \(profile.user.name)")
        return profile
    }
    
    public func updateUserPreferences(_ preferences: UserPreferences) async throws -> UserPreferences {
        print("⚙️ Updating user preferences")
        
        // Update via network
        let updatedPreferences: UserPreferences = try await networkService.request(.userPreferences, responseType: UserPreferences.self)
        
        // Clear related cache
        try await cacheService.remove(key: "preferences")
        
        print("✅ Updated user preferences")
        return updatedPreferences
    }
    
    public func getUserStatistics(id: String) async throws -> UserStatistics {
        print("📈 Fetching user statistics for ID: \(id)")
        
        // Try cache first
        if let cachedStats: UserStatistics = try await cacheService.get(key: "stats_\(id)") {
            print("✅ Found cached statistics")
            return cachedStats
        }
        
        // Fetch from network
        let statistics: UserStatistics = try await networkService.request(.userStatistics, responseType: UserStatistics.self)
        
        // Cache the result
        try await cacheService.set(key: "stats_\(id)", value: statistics, ttl: 1800) // 30 minutes
        
        print("✅ Fetched statistics: \(statistics.totalPosts) posts, \(statistics.totalLikes) likes")
        return statistics
    }
    
    public func uploadAvatar(data: Data) async throws -> String {
        print("📤 Uploading avatar data (\(data.count) bytes)")
        
        // Upload via network
        let avatarURL: String = try await networkService.upload(.uploadAvatar, data: data, responseType: String.self)
        
        print("✅ Avatar uploaded successfully: \(avatarURL)")
        return avatarURL
    }
}

// MARK: - Cache Service Protocol
public protocol CacheServiceProtocol: Sendable {
    func get<T: Codable>(key: String) async throws -> T?
    func set<T: Codable>(key: String, value: T, ttl: TimeInterval) async throws
    func remove(key: String) async throws
    func clear() async throws
}

// MARK: - In-Memory Cache Service
public final class InMemoryCacheService: CacheServiceProtocol {
    private var cache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "cache.queue", attributes: .concurrent)
    
    public init() {}
    
    public func get<T: Codable>(key: String) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                guard let entry = self.cache[key] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Check if expired
                if entry.expiresAt < Date() {
                    self.cache.removeValue(forKey: key)
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: entry.data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func set<T: Codable>(key: String, value: T, ttl: TimeInterval) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    let data = try JSONEncoder().encode(value)
                    let entry = CacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
                    self.cache[key] = entry
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func remove(key: String) async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.cache.removeValue(forKey: key)
                continuation.resume()
            }
        }
    }
    
    public func clear() async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.cache.removeAll()
                continuation.resume()
            }
        }
    }
}

// MARK: - Cache Entry
private struct CacheEntry {
    let data: Data
    let expiresAt: Date
}

// MARK: - Repository Error
public enum RepositoryError: LocalizedError, Sendable {
    case userNotFound
    case cacheError
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .cacheError:
            return "Cache operation failed"
        case .networkError:
            return "Network operation failed"
        }
    }
}
