//
//  DITokenValidation.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

@available(iOS 13.0, macOS 10.15, *)
public protocol DITokenValidationProvider: Sendable {
    func validateToken(_ token: String) async throws -> TokenValidationResult
    func refreshToken(_ token: String) async throws -> String
    func revokeToken(_ token: String) async throws
}

@available(iOS 13.0, macOS 10.15, *)
public struct TokenValidationResult: Sendable, Codable {
    public let isValid: Bool
    public let expiresAt: Date?
    public let permissions: [String]
    public let userId: String?
    public let plan: String?
    
    public init(
        isValid: Bool,
        expiresAt: Date? = nil,
        permissions: [String] = [],
        userId: String? = nil,
        plan: String? = nil
    ) {
        self.isValid = isValid
        self.expiresAt = expiresAt
        self.permissions = permissions
        self.userId = userId
        self.plan = plan
    }
}

@available(iOS 13.0, macOS 10.15, *)
public final class DefaultDITokenValidationProvider: DITokenValidationProvider, Sendable {
    public static let shared = DefaultDITokenValidationProvider()
    
    private let baseURL = "https://api.godare.app"
    private let session = URLSession.shared
    
    private init() {}
    
    public func validateToken(_ token: String) async throws -> TokenValidationResult {
        guard let url = URL(string: "\(baseURL)/validate-token") else {
            throw DITokenValidationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DITokenValidationError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode(TokenValidationResult.self, from: data)
            case 401:
                throw DITokenValidationError.invalidToken
            case 403:
                throw DITokenValidationError.tokenExpired
            default:
                throw DITokenValidationError.serverError(httpResponse.statusCode)
            }
        } catch {
            if error is DITokenValidationError {
                throw error
            } else {
                throw DITokenValidationError.networkError(error)
            }
        }
    }
    
    public func refreshToken(_ token: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/refresh-token") else {
            throw DITokenValidationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw DITokenValidationError.refreshFailed
            }
            
            let result = try JSONDecoder().decode(TokenRefreshResult.self, from: data)
            return result.newToken
        } catch {
            if error is DITokenValidationError {
                throw error
            } else {
                throw DITokenValidationError.networkError(error)
            }
        }
    }
    
    public func revokeToken(_ token: String) async throws {
        guard let url = URL(string: "\(baseURL)/revoke-token") else {
            throw DITokenValidationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw DITokenValidationError.revokeFailed
            }
        } catch {
            if error is DITokenValidationError {
                throw error
            } else {
                throw DITokenValidationError.networkError(error)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
private struct TokenRefreshResult: Codable {
    let newToken: String
    let expiresAt: Date
}

@available(iOS 13.0, macOS 10.15, *)
public enum DITokenValidationError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case invalidToken
    case tokenExpired
    case refreshFailed
    case revokeFailed
    case serverError(Int)
    case networkError(Error)
    case invalidTokenFormat
    case validationFailed(Error)
}
