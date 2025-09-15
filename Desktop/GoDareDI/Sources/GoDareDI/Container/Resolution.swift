//
//  Resolution.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Resolution Extensions
@available(iOS 13.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Resolution
    public func resolve<T: Sendable>() async throws -> T {
        let key = String(describing: T.self)
        return try await resolveInternal(key: key)
    }
    
    public func resolve<T: Sendable>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        return try await resolveInternal(key: key)
    }
    
    // Synchronous resolution for cached instances
    public func resolveSync<T: Sendable>() throws -> T {
        let key = String(describing: T.self)
        return try resolveInternalSync(key: key)
    }
    
    public func resolveSync<T: Sendable>(_ type: T.Type) throws -> T {
        let key = String(describing: type)
        return try resolveInternalSync(key: key)
    }
    
    internal func resolveInternal<T: Sendable>(key: String) async throws -> T {
        let startTime = Date()
        print("🔍 Resolving: \(key)")
        
        // Check for circular dependencies based on configuration
        if config.enableCircularDependencyDetection && resolutionStack.contains(key) {
            let lastIndex = resolutionStack.lastIndex(of: key) ?? -1
            if lastIndex >= 0 && resolutionStack.count - lastIndex >= config.maxCircularDependencyDepth {
                let cycle = Array(resolutionStack[lastIndex...]) + [key]
                
                // 🔥 CRASHLYTICS: Track circular dependency
                if let analyticsProvider = analyticsProvider {
                    analyticsProvider.trackError(CircularDependencyException("Circular dependency detected", cycle: cycle), context: [
                        "cycle": cycle,
                        "component": "GoDareDI"
                    ])
                }
                
                throw CircularDependencyException("Circular dependency detected: \(cycle.joined(separator: " -> "))", cycle: cycle)
            }
        }
        
        // Add to resolution stack
        resolutionStack.append(key)
        defer { resolutionStack.removeLast() }
        
        // Track dependencies during resolution based on configuration
        if config.enableDependencyTracking && resolutionStack.count > 1 {
            let caller = resolutionStack[resolutionStack.count - 2]
            
            if caller != key {
                let isAlreadyCached = (typeRegistry[key]?.scope == .singleton && singletons[key] != nil) ||
                                    (typeRegistry[key]?.scope == .scoped && scopedInstances[scopeId]?[key] != nil) ||
                                    (typeRegistry[key]?.scope == .lazy && lazyInstances[key] != nil)
                
                if !isAlreadyCached {
                    self.dependencyMap[caller, default: Set()].insert(key)
                    print("🔗 Dependency tracked: \(caller) -> \(key)")
                }
            }
        }
        
        guard let metadata = typeRegistry[key] else {
            throw DependencyResolutionError.notRegistered(key)
        }
        
        let instance: T
        
        do {
            switch metadata.scope {
            case .singleton:
                instance = try await resolveSingleton(key: key, metadata: metadata)
            case .scoped:
                instance = try await resolveScoped(key: key, metadata: metadata)
            case .transient:
                instance = try await resolveTransient(key: key, metadata: metadata)
            case .lazy:
                instance = try await resolveLazy(key: key, metadata: metadata)
            }
        } catch {
            print("❌ Failed to resolve \(key): \(error)")
            
            // 🔥 CRASHLYTICS: Track resolution error
            if let analyticsProvider = analyticsProvider {
                analyticsProvider.trackError(error, context: [
                    "dependency_type": key,
                    "scope": metadata.scope.rawValue,
                    "lifetime": metadata.lifetime.rawValue,
                    "resolution_stack": resolutionStack,
                    "component": "GoDareDI"
                ])
            }
            
            throw error
        }
        
        // Track performance metrics based on configuration
        let resolutionTime = Date().timeIntervalSince(startTime)
        if config.enablePerformanceMetrics {
            performanceMetrics[key] = resolutionTime
            resolutionCounts[key, default: 0] += 1
        }
        
        // 🔥 CRASHLYTICS: Track successful resolution
        if let analyticsProvider = analyticsProvider {
            analyticsProvider.trackPerformance("dependency_resolution", value: resolutionTime * 1000, unit: "ms")
            analyticsProvider.trackEvent("dependency_resolved", parameters: [
                "type": key,
                "scope": metadata.scope.rawValue,
                "duration_ms": resolutionTime * 1000,
                "success": true
            ])
        }
        
        print("✅ Resolved: \(key) (took \(String(format: "%.3f", resolutionTime))s)")
        return instance
    }
    
    // MARK: - Helper Methods
    private func getCurrentContainerState() -> [String: Any] {
        return [
            "registeredServicesCount": factories.count,
            "activeScopes": Array(scopedInstances.keys),
            "currentScope": scopeId,
            "isPreloading": false // This would be tracked if we had preloading state
        ]
    }
    
    private func resolveInternalSync<T: Sendable>(key: String) throws -> T {
        print("🔍 Resolving synchronously: \(key)")
        
        // Check for circular dependencies based on configuration
        if config.enableCircularDependencyDetection && resolutionStack.contains(key) {
            let cycle = resolutionStack + [key]
            throw CircularDependencyException("Circular dependency detected: \(cycle.joined(separator: " -> "))", cycle: cycle)
        }
        
        // Add to resolution stack
        resolutionStack.append(key)
        defer { resolutionStack.removeLast() }
        
        guard let metadata = typeRegistry[key] else {
            throw DependencyResolutionError.notRegistered(key)
        }
        
        // For sync resolution, only cached instances can be returned
        switch metadata.scope {
        case .singleton:
            if config.enableCaching, let existing = singletons[key] as? T {
                if config.enablePerformanceMetrics {
                    cacheHits[key, default: 0] += 1
                }
                return existing
            }
        case .scoped:
            if config.enableCaching, let existing = scopedInstances[scopeId]?[key] as? T {
                if config.enablePerformanceMetrics {
                    cacheHits[key, default: 0] += 1
                }
                return existing
            }
        case .lazy:
            if config.enableCaching, let existing = lazyInstances[key] as? T {
                if config.enablePerformanceMetrics {
                    cacheHits[key, default: 0] += 1
                }
                return existing
            }
        case .transient:
            break // Transient instances can't be cached
        }
        
        throw DependencyResolutionError.factoryError("Instance not available for synchronous resolution")
    }
}
