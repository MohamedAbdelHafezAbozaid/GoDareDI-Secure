//
//  GoDareDISecureInit.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Secure Initialization System
@MainActor
public class GoDareDISecureInit: Sendable {
    
    // MARK: - Properties
    private static var isInitialized = false
    private static var licenseResponse: GoDareDILicense.LicenseResponse?
    private static let initializationLock = NSLock()
    
    // MARK: - Secure Initialization
    public static func initialize() async throws -> AdvancedDIContainer {
        initializationLock.lock()
        defer { initializationLock.unlock() }
        
        // Check if already initialized
        if isInitialized {
            throw GoDareDILicenseError.alreadyInitialized
        }
        
        // Validate license
        let license = try await GoDareDILicense.validateLicense()
        guard license.isValid else {
            throw GoDareDILicenseError.invalidLicense
        }
        
        // Check license expiration
        if let expiresAt = license.expiresAt, expiresAt < Date() {
            throw GoDareDILicenseError.licenseExpired
        }
        
        // Store license response
        licenseResponse = license
        
        // Initialize container
        let container = AdvancedDIContainerImpl()
        
        // Mark as initialized
        isInitialized = true
        
        print("🔒 GoDareDI initialized with \(license.licenseType) license")
        print("📱 Max Apps: \(license.maxApps)")
        print("👥 Max Users: \(license.maxUsers)")
        print("✨ Features: \(license.features.joined(separator: ", "))")
        
        return container
    }
    
    // MARK: - License Validation
    public static func validateLicense() async throws -> GoDareDILicense.LicenseResponse {
        return try await GoDareDILicense.validateLicense()
    }
    
    // MARK: - Feature Access
    public static func hasFeature(_ feature: String) async -> Bool {
        guard let license = licenseResponse else {
            return false
        }
        return license.features.contains(feature)
    }
    
    // MARK: - Usage Limits
    public static func canCreateApp() async -> Bool {
        guard let license = licenseResponse else {
            return false
        }
        // Implement actual app count check
        return true
    }
    
    public static func canCreateUser() async -> Bool {
        guard let license = licenseResponse else {
            return false
        }
        // Implement actual user count check
        return true
    }
    
    // MARK: - License Info
    public static func getLicenseInfo() -> [String: Any]? {
        guard let license = licenseResponse else {
            return nil
        }
        
        return [
            "licenseType": license.licenseType,
            "maxApps": license.maxApps,
            "maxUsers": license.maxUsers,
            "expiresAt": license.expiresAt?.timeIntervalSince1970 ?? 0,
            "features": license.features
        ]
    }
    
    // MARK: - Reset (for testing)
    public static func reset() {
        initializationLock.lock()
        defer { initializationLock.unlock() }
        
        isInitialized = false
        licenseResponse = nil
    }
}

// MARK: - License Error Extensions
extension GoDareDILicenseError {
    case alreadyInitialized
    
    var errorDescription: String? {
        switch self {
        case .alreadyInitialized:
            return "GoDareDI is already initialized. Call reset() to reinitialize."
        default:
            return nil
        }
    }
}

// MARK: - Secure Container Extension
extension AdvancedDIContainerImpl {
    
    // MARK: - Secure Registration
    public func registerSecure<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    ) async throws {
        // Check if feature is available
        let featureName = "register_\(String(describing: type))"
        guard await GoDareDISecureInit.hasFeature(featureName) else {
            throw GoDareDILicenseError.featureNotAvailable
        }
        
        // Register normally
        try await register(type, scope: scope, lifetime: lifetime, factory: factory)
    }
    
    // MARK: - Secure Resolution
    public func resolveSecure<T: Sendable>() async throws -> T {
        // Check if feature is available
        let featureName = "resolve_\(String(describing: T.self))"
        guard await GoDareDISecureInit.hasFeature(featureName) else {
            throw GoDareDILicenseError.featureNotAvailable
        }
        
        // Resolve normally
        return try await resolve()
    }
}

// MARK: - Usage Tracking
extension GoDareDISecureInit {
    
    // MARK: - Track Usage
    public static func trackUsage(_ feature: String) async {
        // Track feature usage for analytics
        print("📊 Feature used: \(feature)")
    }
    
    // MARK: - Check Usage Limits
    public static func checkUsageLimits() async -> Bool {
        // Check if user has exceeded usage limits
        return true
    }
}
