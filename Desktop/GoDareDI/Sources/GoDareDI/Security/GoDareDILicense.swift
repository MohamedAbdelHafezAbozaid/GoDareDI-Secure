//
//  GoDareDILicense.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation
import CryptoKit

// MARK: - License Validation System
@MainActor
public class GoDareDILicense: Sendable {
    
    // MARK: - Properties
    private static let tokenServerURL = "https://us-central1-godaredi-60569.cloudfunctions.net/validateToken"
    private static let tokenKey = "GODARE_TOKEN_KEY"
    
    // MARK: - License Types
    public enum LicenseType: String, CaseIterable, Sendable {
        case trial = "trial"
        case personal = "personal"
        case commercial = "commercial"
        case enterprise = "enterprise"
        
        public var maxApps: Int {
            switch self {
            case .trial: return 1
            case .personal: return 3
            case .commercial: return 10
            case .enterprise: return Int.max
            }
        }
        
        public var maxUsers: Int {
            switch self {
            case .trial: return 1
            case .personal: return 5
            case .commercial: return 50
            case .enterprise: return Int.max
            }
        }
    }
    
    // MARK: - Token Response
    public struct TokenResponse: Codable, Sendable {
        let success: Bool
        let valid: Bool
        let appId: String
        let userId: String
    }
    
    // MARK: - Token Validation
    public static func validateToken() async throws -> TokenResponse {
        guard let token = getToken() else {
            throw GoDareDILicenseError.noLicenseKey
        }
        
        let url = URL(string: tokenServerURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "data": [
                "token": token
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoDareDILicenseError.networkError
        }
        
        print("📡 Server response status: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            return tokenResponse
        case 400:
            print("❌ Server validation failed: Server error 400")
            throw GoDareDILicenseError.invalidLicense
        case 401:
            throw GoDareDILicenseError.invalidLicense
        case 403:
            throw GoDareDILicenseError.licenseExpired
        default:
            print("❌ Server validation failed: Network error - Server error during token validation (HTTP \(httpResponse.statusCode)). Please try again later.")
            throw GoDareDILicenseError.serverError
        }
    }
    
    // MARK: - Local Token Validation
    public static func validateLocalToken() -> Bool {
        guard let token = getToken() else { return false }
        
        // Basic token format validation (64 character hex string)
        let tokenPattern = "^[a-f0-9]{64}$"
        let regex = try? NSRegularExpression(pattern: tokenPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: token.utf16.count)
        
        return regex?.firstMatch(in: token, options: [], range: range) != nil
    }
    
    // MARK: - Token Management
    private static func getToken() -> String? {
        // Check environment variable first
        if let envToken = ProcessInfo.processInfo.environment[tokenKey] {
            return envToken
        }
        
        // Check UserDefaults
        if let userDefaultsToken = UserDefaults.standard.string(forKey: tokenKey) {
            return userDefaultsToken
        }
        
        // Check Info.plist
        if let infoPlistToken = Bundle.main.infoDictionary?[tokenKey] as? String {
            return infoPlistToken
        }
        
        return nil
    }
    
    public static func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    // MARK: - Feature Validation (All features available with valid token)
    public static func hasFeature(_ feature: String) async -> Bool {
        do {
            let _ = try await validateToken()
            return true // All features available with valid token
        } catch {
            return false
        }
    }
    
    // MARK: - Usage Limits (No limits with valid token)
    public static func canCreateApp() async -> Bool {
        do {
            let _ = try await validateToken()
            return true // No limits with valid token
        } catch {
            return false
        }
    }
    
    public static func canCreateUser() async -> Bool {
        do {
            let _ = try await validateToken()
            return true // No limits with valid token
        } catch {
            return false
        }
    }
}

// MARK: - Token Errors
public enum GoDareDILicenseError: Error, LocalizedError {
    case noLicenseKey
    case invalidLicense
    case licenseExpired
    case networkError
    case serverError
    case featureNotAvailable
    case alreadyInitialized
    
    public var errorDescription: String? {
        switch self {
        case .noLicenseKey:
            return "No token found. Please set your GoDareDI token. Get your token from https://godare.app/"
        case .invalidLicense:
            return "Invalid token. Please check your token or generate a new one from https://godare.app/"
        case .licenseExpired:
            return "Token has expired. Please generate a new token from https://godare.app/"
        case .networkError:
            return "Network error. Please check your internet connection."
        case .serverError:
            return "Server error during token validation (HTTP 400). Please try again later."
        case .featureNotAvailable:
            return "This feature requires a valid token. Get your token from https://godare.app/"
        case .alreadyInitialized:
            return "GoDareDI is already initialized. Call reset() to reinitialize."
        }
    }
}

// MARK: - Token Validation Extensions
extension GoDareDILicense {
    
    // MARK: - Token Status
    public static func getTokenStatus() async -> String {
        do {
            let response = try await validateToken()
            return "Valid token for app: \(response.appId)"
        } catch {
            return "Invalid token: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Token Info
    public static func getTokenInfo() async -> [String: Any] {
        do {
            let response = try await validateToken()
            return [
                "isValid": response.valid,
                "appId": response.appId,
                "userId": response.userId,
                "success": response.success
            ]
        } catch {
            return [
                "isValid": false,
                "error": error.localizedDescription
            ]
        }
    }
}
