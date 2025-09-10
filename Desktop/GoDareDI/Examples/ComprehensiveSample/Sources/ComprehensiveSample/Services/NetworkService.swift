//
//  NetworkService.swift
//  ComprehensiveSample
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Network Service Protocol
public protocol NetworkServiceProtocol: Sendable {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    func upload<T: Codable>(_ endpoint: APIEndpoint, data: Data, responseType: T.Type) async throws -> T
}

// MARK: - API Endpoint
public enum APIEndpoint: String, CaseIterable, Sendable {
    case users = "/api/users"
    case userProfile = "/api/users/profile"
    case userPreferences = "/api/users/preferences"
    case userStatistics = "/api/users/statistics"
    case uploadAvatar = "/api/users/avatar"
    
    public var url: String {
        return "https://api.example.com\(rawValue)"
    }
}

// MARK: - Network Service Implementation
public final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let baseURL: String
    
    public init(session: URLSession = .shared, baseURL: String = "https://api.example.com") {
        self.session = session
        self.baseURL = baseURL
    }
    
    public func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        print("🌐 Making request to: \(endpoint.url)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...2_000_000_000))
        
        // Simulate different responses based on endpoint
        let response = try await simulateResponse(for: endpoint, responseType: responseType)
        
        print("✅ Request completed successfully")
        return response
    }
    
    public func upload<T: Codable>(_ endpoint: APIEndpoint, data: Data, responseType: T.Type) async throws -> T {
        print("📤 Uploading data to: \(endpoint.url)")
        
        // Simulate upload delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...3_000_000_000))
        
        // Simulate upload response
        let response = try await simulateUploadResponse(for: endpoint, data: data, responseType: responseType)
        
        print("✅ Upload completed successfully")
        return response
    }
    
    // MARK: - Private Methods
    private func simulateResponse<T: Codable>(for endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        switch endpoint {
        case .users:
            if responseType == [User].self {
                let users = [
                    User(id: "1", name: "John Doe", email: "john@example.com"),
                    User(id: "2", name: "Jane Smith", email: "jane@example.com"),
                    User(id: "3", name: "Bob Johnson", email: "bob@example.com")
                ]
                return users as! T
            }
        case .userProfile:
            if responseType == UserProfile.self {
                let user = User(id: "1", name: "John Doe", email: "john@example.com")
                let preferences = UserPreferences(theme: "dark", language: "en", notifications: true)
                let statistics = UserStatistics(totalPosts: 42, totalLikes: 128, joinDate: Date().addingTimeInterval(-86400 * 30))
                let profile = UserProfile(user: user, preferences: preferences, statistics: statistics)
                return profile as! T
            }
        case .userPreferences:
            if responseType == UserPreferences.self {
                let preferences = UserPreferences(theme: "dark", language: "en", notifications: true)
                return preferences as! T
            }
        case .userStatistics:
            if responseType == UserStatistics.self {
                let statistics = UserStatistics(totalPosts: 42, totalLikes: 128, joinDate: Date().addingTimeInterval(-86400 * 30))
                return statistics as! T
            }
        case .uploadAvatar:
            if responseType == String.self {
                return "https://api.example.com/avatars/uploaded_avatar.jpg" as! T
            }
        }
        
        throw NetworkError.invalidResponse
    }
    
    private func simulateUploadResponse<T: Codable>(for endpoint: APIEndpoint, data: Data, responseType: T.Type) async throws -> T {
        switch endpoint {
        case .uploadAvatar:
            if responseType == String.self {
                return "https://api.example.com/avatars/uploaded_avatar.jpg" as! T
            }
        default:
            break
        }
        
        throw NetworkError.invalidResponse
    }
}

// MARK: - Network Error
public enum NetworkError: LocalizedError, Sendable {
    case invalidResponse
    case networkUnavailable
    case timeout
    case unauthorized
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .networkUnavailable:
            return "Network is unavailable"
        case .timeout:
            return "Request timed out"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
