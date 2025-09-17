//
//  AdvancedDIContainer.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Advanced DI Container Protocol
@MainActor
public protocol AdvancedDIContainer: Sendable {
    // MARK: - Core Registration (Async)
    func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    )
    
    func register<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) async throws -> T
    )
    
    // MARK: - Core Registration (Sync) - NEW!
    func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        lifetime: DependencyLifetime,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    )
    
    func registerSync<T: Sendable>(
        _ type: T.Type,
        scope: DependencyScope,
        factory: @escaping @Sendable (AdvancedDIContainer) throws -> T
    )
    
    // MARK: - Resolution
    func resolve<T: Sendable>() async throws -> T
    func resolve<T: Sendable>(_ type: T.Type) async throws -> T
    
    // Synchronous resolution for cached instances
    func resolveSync<T: Sendable>() throws -> T
    func resolveSync<T: Sendable>(_ type: T.Type) throws -> T
    
    // MARK: - Scope Management
    func createScope(_ scopeId: String) async
    func disposeScope(_ scopeId: String) async
    func setCurrentScope(_ scopeId: String) async
    func getCurrentScope() -> String
    
    // MARK: - Analysis and Validation
    func validateDependencies() async throws
    func getDependencyGraph() async -> DependencyGraph
    func analyzeDependencyGraph() async -> GraphAnalysis
    func analyzeDependencyGraphWithMetrics() async -> GraphAnalysis
    func isRegistered<T>(_ type: T.Type) -> Bool
    
    // MARK: - Performance and Monitoring
    func getPerformanceMetrics() async -> PerformanceMetrics
    func preloadDependencies() async
    func cleanup() async
    
    // MARK: - Generic Preloading (NEW!)
    func preloadAllGeneric() async throws
    func preloadSmart() async throws
    func preloadViewModelsOnly() async throws
    
    // MARK: - Metadata
    func getMetadata<T>(_ type: T.Type) -> DependencyMetadata?
    func registerWithMetadata<T>(_ type: T.Type, metadata: DependencyMetadata)
    
    // MARK: - Metadata Access
    func getMetadata(for key: String) -> DependencyMetadata?
    func getDependencyMap() -> [String: Set<String>]
    
    func getRegisteredServicesCount() -> Int
    
    // MARK: - Debug Methods
    func debugPrintMetadata()
    func debugPrintFactories()
}
