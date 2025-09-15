//
//  AdvancedDIContainerImpl.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

@MainActor
public final class AdvancedDIContainerImpl: AdvancedDIContainer, Sendable {
    
    // MARK: - Properties
    internal let config: DIContainerConfig
    public var singletons: [String: Sendable] = [:]
    internal var scopedInstances: [String: [String: Sendable]] = [:]
    internal var lazyInstances: [String: Sendable] = [:]
    internal var resolutionStack: [String] = []
    internal var scopeId: String = "default"
    internal var dependencyMap: [String: Set<String>] = [:]
    internal var performanceMetrics: [String: TimeInterval] = [:]
    internal var resolutionCounts: [String: Int] = [:]
    internal var cacheHits: [String: Int] = [:]
    public var factories: [String: FactoryType] = [:]
    
    // 🚀 UNIFIED: Single metadata storage for both resolution and preloading
    internal var typeRegistry: [String: DependencyMetadata] = [:]
    
    // 🔥 CRASHLYTICS: Analytics and crashlytics integration
    internal var analyticsProvider: DIAnalyticsProvider?
    internal var crashlyticsConfig: DICrashlyticsConfig?
    
    // MARK: - Factory Union Type
    public enum FactoryType: Sendable {
        case sync(@Sendable (AdvancedDIContainer) throws -> Sendable)
        case async(@Sendable (AdvancedDIContainer) async throws -> Sendable)
    }
    
    // MARK: - Initialization (Token Required)
    public init(config: DIContainerConfig = DIContainerConfig()) {
        self.config = config
        // Token validation is handled by GoDareDISecureInit.initialize()
    }
    
    // MARK: - Analytics Initialization
    public init(config: DIContainerConfig = DIContainerConfig(), crashlyticsConfig: DICrashlyticsConfig) async throws {
        self.config = config
        self.crashlyticsConfig = crashlyticsConfig
        
        // 🔥 ANALYTICS: Validate token before initialization
        try await validateToken(crashlyticsConfig.token)
        
        self.analyticsProvider = DICrashlyticsIntegration(token: crashlyticsConfig.token)
    }
    
    // MARK: - Direct Token Initialization (Deprecated - Use GoDareDISecureInit.initialize())
    @available(*, deprecated, message: "Use GoDareDISecureInit.initialize() instead. Set token with GoDareDILicense.setToken() first.")
    public init(config: DIContainerConfig = DIContainerConfig(), token: String) async throws {
        self.config = config
        
        // Set token for validation
        GoDareDILicense.setToken(token)
        
        // Validate token using the secure initialization
        let _ = try await GoDareDILicense.validateToken()
        
        // 🔥 ANALYTICS: Create analytics config from token
        let crashlyticsConfig = DICrashlyticsConfig(token: token)
        self.crashlyticsConfig = crashlyticsConfig
        
        // 🔥 ANALYTICS: Initialize analytics provider
        self.analyticsProvider = DICrashlyticsIntegration(token: token)
    }
    
    // MARK: - Token Access
    public var token: String? {
        return crashlyticsConfig?.token
    }
    
    public var hasValidToken: Bool {
        return crashlyticsConfig?.token != nil
    }
    
    // MARK: - Freemium Support
    public var isFreemiumMode: Bool {
        return crashlyticsConfig == nil
    }
    
    public func upgradeToPremium(token: String) async throws {
        print("🚀 Starting premium upgrade process...")
        print("🔑 Token: \(token.prefix(8))...")
        
        // Validate the new token
        try await validateToken(token)
        
        // Create analytics config with the new token
        let newCrashlyticsConfig = DICrashlyticsConfig(token: token)
        self.crashlyticsConfig = newCrashlyticsConfig
        
        // Initialize analytics provider
        self.analyticsProvider = DICrashlyticsIntegration(token: token)
        
        print("🎉 Successfully upgraded to Premium!")
        print("✨ All advanced features are now unlocked")
        print("📊 Analytics and crashlytics are now active")
    }
    
    // MARK: - Token Validation
    private func validateToken(_ token: String) async throws {
        print("🔍 Validating token: \(token.prefix(8))...")
        
        // Validate token format (64 character hex string)
        guard token.count == 64 && token.allSatisfy({ $0.isHexDigit }) else {
            print("❌ Token validation failed: Invalid token format")
            print("   Expected: 64-character hexadecimal string")
            print("   Received: \(token.count) characters")
            throw DITokenValidationError.invalidTokenFormat
        }
        
        print("✅ Token format is valid")
        
        // Validate token with server
        do {
            let isValid = try await validateTokenWithServer(token)
            if !isValid {
                print("❌ Token validation failed: Token is invalid or expired")
                print("   Please check your token and try again")
                throw DITokenValidationError.invalidToken
            }
            print("✅ Token is valid and active")
        } catch {
            print("❌ Token validation failed: \(error.localizedDescription)")
            throw DITokenValidationError.validationFailed(error)
        }
    }
    
    private func validateTokenWithServer(_ token: String) async throws -> Bool {
        print("🌐 Validating token with server...")
        
        let url = URL(string: "https://us-central1-godaredi-60569.cloudfunctions.net/validateToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Firebase Callable Functions expect data wrapped in "data" field
        let payload: [String: Any] = [
            "data": ["token": token]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
        
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Network error: Invalid response")
                throw DITokenValidationError.networkError
            }
            
            print("📡 Server response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                // Firebase Callable Functions return data in a "result" field
                if let result = result, let resultData = result["result"] as? [String: Any] {
                    let isValid = resultData["valid"] as? Bool ?? false
                    if isValid {
                        print("✅ Server validation successful: Token is valid")
                    } else {
                        print("❌ Server validation failed: Token is invalid")
                    }
                    return isValid
                }
                print("❌ Server validation failed: Invalid response format")
                return false
            } else if httpResponse.statusCode == 404 {
                print("❌ Server validation failed: Token not found (404)")
                return false // Token not found
            } else {
                print("❌ Server validation failed: Server error \(httpResponse.statusCode)")
                throw DITokenValidationError.serverError(httpResponse.statusCode)
            }
        } catch {
            print("❌ Server validation failed: Network error - \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Dependency Graph Analysis Extensions
extension DependencyGraph {
    
    func findCircularDependencies() -> [[String]] {
        var visited: Set<String> = []
        var recursionStack: Set<String> = []
        var circularDeps: [[String]] = []
        
        for node in nodes {
            if !visited.contains(node.id) {
                var path: [String] = []
                dfs(node: node, visited: &visited, recursionStack: &recursionStack, path: &path, circularDeps: &circularDeps)
            }
        }
        
        return circularDeps
    }
    
    private func dfs(node: DependencyNode, visited: inout Set<String>, recursionStack: inout Set<String>, path: inout [String], circularDeps: inout [[String]]) {
        visited.insert(node.id)
        recursionStack.insert(node.id)
        path.append(node.id)
        
        for dependency in node.dependencies {
            if !visited.contains(dependency) {
                if let depNode = nodes.first(where: { $0.id == dependency }) {
                    dfs(node: depNode, visited: &visited, recursionStack: &recursionStack, path: &path, circularDeps: &circularDeps)
                }
            } else if recursionStack.contains(dependency) {
                if let startIndex = path.firstIndex(of: dependency) {
                    let cycle = Array(path[startIndex...])
                    circularDeps.append(cycle)
                }
            }
        }
        
        recursionStack.remove(node.id)
        path.removeLast()
    }
    
    func getDependencyDepth(for nodeId: String) -> Int {
        return getDependencyDepthHelper(for: nodeId, visited: Set())
    }
    
    private func getDependencyDepthHelper(for nodeId: String, visited: Set<String>) -> Int {
        guard let node = nodes.first(where: { $0.id == nodeId }) else { return 0 }
        
        // Prevent infinite recursion for circular dependencies
        if visited.contains(nodeId) {
            return 0
        }
        
        if node.dependencies.isEmpty {
            return 0
        }
        
        var newVisited = visited
        newVisited.insert(nodeId)
        
        let maxDepth = node.dependencies.map { getDependencyDepthHelper(for: $0, visited: newVisited) }.max() ?? 0
        return maxDepth + 1
    }
    
    func getDependents(for nodeId: String) -> [String] {
        return edges.filter { $0.to == nodeId }.map { $0.from }
    }
    
    func getDependencies(for nodeId: String) -> [String] {
        return edges.filter { $0.from == nodeId }.map { $0.to }
    }
}