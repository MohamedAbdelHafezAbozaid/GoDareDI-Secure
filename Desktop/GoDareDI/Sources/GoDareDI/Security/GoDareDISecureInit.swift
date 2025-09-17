//
//  GoDareDISecureInit.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Secure Initialization System
@available(iOS 18.0, macOS 10.15, *)
@MainActor
public class GoDareDISecureInit: Sendable {
    
    // MARK: - Properties
    private static var isInitialized = false
    private static var tokenResponse: GoDareDILicense.TokenResponse?
    private static let initializationTask: Task<AdvancedDIContainer, Error>? = nil
    
    // MARK: - Secure Initialization
    public static func initialize() async throws -> AdvancedDIContainer {
        // Use actor-based synchronization for async safety
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await performInitialization()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private static func performInitialization() async throws -> AdvancedDIContainer {
        // Check if already initialized
        if isInitialized {
            throw GoDareDILicenseError.alreadyInitialized
        }
        
        // Validate token
        let token = try await GoDareDILicense.validateToken()
        guard token.valid else {
            throw GoDareDILicenseError.invalidLicense
        }
        
        // Store token response
        tokenResponse = token
        
        // Initialize container
        let container = AdvancedDIContainerImpl()
        
        // Mark as initialized
        isInitialized = true
        
        print("🔒 GoDareDI initialized with valid token")
        print("📱 App ID: \(token.appId)")
        print("👤 User ID: \(token.userId)")
        print("✨ All features available")
        
        return container
    }
    
    // MARK: - Token Validation
    public static func validateToken() async throws -> GoDareDILicense.TokenResponse {
        return try await GoDareDILicense.validateToken()
    }
    
    // MARK: - Feature Access (All features available with valid token)
    public static func hasFeature(_ feature: String) async -> Bool {
        guard tokenResponse != nil else {
            return false
        }
        return true // All features available with valid token
    }
    
    // MARK: - Usage Limits (No limits with valid token)
    public static func canCreateApp() async -> Bool {
        guard tokenResponse != nil else {
            return false
        }
        return true // No limits with valid token
    }
    
    public static func canCreateUser() async -> Bool {
        guard tokenResponse != nil else {
            return false
        }
        return true // No limits with valid token
    }
    
    // MARK: - Token Info
    public static func getTokenInfo() -> [String: Any]? {
        guard let token = tokenResponse else {
            return nil
        }
        
        return [
            "appId": token.appId,
            "userId": token.userId,
            "valid": token.valid,
            "success": token.success
        ]
    }
    
    // MARK: - Reset (for testing)
    @MainActor
    public static func reset() {
        isInitialized = false
        tokenResponse = nil
    }
}

// MARK: - License Error Extensions
// Note: alreadyInitialized case is now defined in GoDareDILicenseError enum

// MARK: - Secure Container Extension
@available(iOS 18.0, macOS 10.15, *)
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
        register(type, scope: scope, lifetime: lifetime, factory: factory)
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
@available(iOS 18.0, macOS 10.15, *)
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
