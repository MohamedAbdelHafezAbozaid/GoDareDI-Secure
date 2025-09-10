//
//  DITokenValidation.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Token Validation Error
public enum DITokenValidationError: Error, Sendable, LocalizedError {
    case invalidTokenFormat
    case invalidToken
    case validationFailed(Error)
    case networkError
    case serverError(Int)
    case tokenExpired
    case tokenInactive
    
    public var errorDescription: String? {
        switch self {
        case .invalidTokenFormat:
            return "Invalid token format. Token must be a 64-character hexadecimal string."
        case .invalidToken:
            return "Invalid token. Please check your token and try again."
        case .validationFailed(let error):
            return "Token validation failed: \(error.localizedDescription)"
        case .networkError:
            return "Network error during token validation. Please check your internet connection."
        case .serverError(let code):
            return "Server error during token validation (HTTP \(code)). Please try again later."
        case .tokenExpired:
            return "Token has expired. Please generate a new token from your dashboard."
        case .tokenInactive:
            return "Token is inactive. Please activate your token from your dashboard."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidTokenFormat:
            return "Please ensure your token is exactly 64 characters long and contains only hexadecimal characters (0-9, a-f)."
        case .invalidToken:
            return "Please visit the GoDareDI dashboard to generate a new token or verify your existing token."
        case .validationFailed:
            return "Please check your internet connection and try again. If the problem persists, contact support."
        case .networkError:
            return "Please check your internet connection and try again."
        case .serverError:
            return "The server is temporarily unavailable. Please try again later."
        case .tokenExpired:
            return "Please visit the GoDareDI dashboard to generate a new token."
        case .tokenInactive:
            return "Please visit the GoDareDI dashboard to activate your token."
        }
    }
}

// MARK: - Token Validation Helper
public struct DITokenValidator: Sendable {
    
    // MARK: - Public Methods
    public static func validateTokenFormat(_ token: String) -> Bool {
        return token.count == 64 && token.allSatisfy { $0.isHexDigit }
    }
    
    public static func validateTokenWithFirebase(_ token: String) async throws -> Bool {
        let url = URL(string: "https://us-central1-godaredi-60569.cloudfunctions.net/validateToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = ["data": ["token": token]]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DITokenValidationError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let result = result, let resultData = result["result"] as? [String: Any] {
                return resultData["valid"] as? Bool ?? false
            }
            return false
        case 404:
            return false // Token not found
        case 410:
            throw DITokenValidationError.tokenExpired
        case 403:
            throw DITokenValidationError.tokenInactive
        default:
            throw DITokenValidationError.serverError(httpResponse.statusCode)
        }
    }
    
    public static func validateToken(_ token: String) async throws {
        // Validate format
        guard validateTokenFormat(token) else {
            throw DITokenValidationError.invalidTokenFormat
        }
        
        // Validate with Firebase
        let isValid = try await validateTokenWithFirebase(token)
        if !isValid {
            throw DITokenValidationError.invalidToken
        }
    }
}

// MARK: - Token Info
public struct DITokenInfo: Sendable {
    public let token: String
    public let appName: String
    public let platform: String
    public let bundleId: String
    public let isActive: Bool
    public let createdAt: Date
    public let lastUsed: Date?
    public let usageCount: Int
    
    public init(token: String, appName: String, platform: String, bundleId: String, isActive: Bool, createdAt: Date, lastUsed: Date? = nil, usageCount: Int = 0) {
        self.token = token
        self.appName = appName
        self.platform = platform
        self.bundleId = bundleId
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Token Validation Result
public enum DITokenValidationResult: Sendable {
    case valid(DITokenInfo)
    case invalid(DITokenValidationError)
    case expired
    case inactive
    case networkError(Error)
}
