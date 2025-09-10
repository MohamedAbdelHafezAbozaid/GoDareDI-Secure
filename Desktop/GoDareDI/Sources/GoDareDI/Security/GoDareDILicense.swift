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
    private static let licenseServerURL = "https://godaredi-60569.web.app/api/validate-license"
    private static let licenseKey = "GODARE_LICENSE_KEY"
    
    // MARK: - License Types
    public enum LicenseType: String, CaseIterable {
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
    
    // MARK: - License Response
    public struct LicenseResponse: Codable {
        let isValid: Bool
        let licenseType: String
        let maxApps: Int
        let maxUsers: Int
        let expiresAt: Date?
        let features: [String]
        let message: String?
    }
    
    // MARK: - License Validation
    public static func validateLicense() async throws -> LicenseResponse {
        guard let licenseKey = getLicenseKey() else {
            throw GoDareDILicenseError.noLicenseKey
        }
        
        let url = URL(string: licenseServerURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(licenseKey)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "licenseKey": licenseKey,
            "bundleId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "platform": "ios"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoDareDILicenseError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200:
            let licenseResponse = try JSONDecoder().decode(LicenseResponse.self, from: data)
            return licenseResponse
        case 401:
            throw GoDareDILicenseError.invalidLicense
        case 403:
            throw GoDareDILicenseError.licenseExpired
        default:
            throw GoDareDILicenseError.serverError
        }
    }
    
    // MARK: - Local License Validation
    public static func validateLocalLicense() -> Bool {
        guard let licenseKey = getLicenseKey() else { return false }
        
        // Basic license key format validation
        let licensePattern = "^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$"
        let regex = try? NSRegularExpression(pattern: licensePattern)
        let range = NSRange(location: 0, length: licenseKey.utf16.count)
        
        return regex?.firstMatch(in: licenseKey, options: [], range: range) != nil
    }
    
    // MARK: - License Key Management
    private static func getLicenseKey() -> String? {
        // Check environment variable first
        if let envKey = ProcessInfo.processInfo.environment[licenseKey] {
            return envKey
        }
        
        // Check UserDefaults
        if let userDefaultsKey = UserDefaults.standard.string(forKey: licenseKey) {
            return userDefaultsKey
        }
        
        // Check Info.plist
        if let infoPlistKey = Bundle.main.infoDictionary?[licenseKey] as? String {
            return infoPlistKey
        }
        
        return nil
    }
    
    public static func setLicenseKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: licenseKey)
    }
    
    // MARK: - Feature Validation
    public static func hasFeature(_ feature: String) async -> Bool {
        do {
            let response = try await validateLicense()
            return response.features.contains(feature)
        } catch {
            return false
        }
    }
    
    // MARK: - Usage Limits
    public static func canCreateApp() async -> Bool {
        do {
            let response = try await validateLicense()
            // Check if user has reached app limit
            return true // Implement actual app count check
        } catch {
            return false
        }
    }
    
    public static func canCreateUser() async -> Bool {
        do {
            let response = try await validateLicense()
            // Check if user has reached user limit
            return true // Implement actual user count check
        } catch {
            return false
        }
    }
}

// MARK: - License Errors
public enum GoDareDILicenseError: Error, LocalizedError {
    case noLicenseKey
    case invalidLicense
    case licenseExpired
    case networkError
    case serverError
    case featureNotAvailable
    
    public var errorDescription: String? {
        switch self {
        case .noLicenseKey:
            return "No license key found. Please set your license key."
        case .invalidLicense:
            return "Invalid license key. Please check your license key."
        case .licenseExpired:
            return "License has expired. Please renew your license."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .serverError:
            return "Server error. Please try again later."
        case .featureNotAvailable:
            return "This feature is not available in your license."
        }
    }
}

// MARK: - License Validation Extensions
extension GoDareDILicense {
    
    // MARK: - Trial License
    public static func startTrial() async throws -> LicenseResponse {
        let trialKey = "TRIAL-\(UUID().uuidString.prefix(8).uppercased())"
        setLicenseKey(trialKey)
        return try await validateLicense()
    }
    
    // MARK: - License Status
    public static func getLicenseStatus() async -> String {
        do {
            let response = try await validateLicense()
            return "Valid \(response.licenseType) license"
        } catch {
            return "Invalid license: \(error.localizedDescription)"
        }
    }
    
    // MARK: - License Info
    public static func getLicenseInfo() async -> [String: Any] {
        do {
            let response = try await validateLicense()
            return [
                "isValid": response.isValid,
                "licenseType": response.licenseType,
                "maxApps": response.maxApps,
                "maxUsers": response.maxUsers,
                "expiresAt": response.expiresAt?.timeIntervalSince1970 ?? 0,
                "features": response.features
            ]
        } catch {
            return [
                "isValid": false,
                "error": error.localizedDescription
            ]
        }
    }
}
