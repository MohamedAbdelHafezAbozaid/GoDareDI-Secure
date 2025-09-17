//
//  ScopeResolution.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Scope Resolution Extensions
@available(iOS 18.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Scope-Specific Resolution
    internal func resolveSingleton<T: Sendable>(key: String, metadata: DependencyMetadata) async throws -> T {
        print("🔄 resolveSingleton called for: \(key)")
        
        if config.enableCaching, let existing = singletons[key] as? T {
            print("   ✅ Found cached instance for: \(key)")
            if config.enablePerformanceMetrics {
                cacheHits[key, default: 0] += 1
            }
            return existing
        }
        
        print("   🔄 Creating new instance for: \(key)")
        
        // Create new instance using factory (sync or async)
        guard let factoryType = getFactory(for: key) else {
            throw DependencyResolutionError.factoryError("No factory found for \(key)")
        }
        
        let sendableInstance: Sendable
        switch factoryType {
        case .sync(let syncFactory):
            sendableInstance = try syncFactory(self)
        case .async(let asyncFactory):
            sendableInstance = try await asyncFactory(self)
        }
        
        guard let instance = sendableInstance as? T else {
            let actualType = String(describing: type(of: sendableInstance))
            throw DependencyResolutionError.typeMismatch("Factory returned \(actualType) but expected \(key)")
        }
        
        if config.enableCaching {
            print("   💾 Caching instance for: \(key)")
            singletons[key] = instance
            print("   ✅ Instance cached successfully for: \(key)")
        } else {
            print("   ⚠️ Caching disabled for: \(key)")
        }
        
        return instance
    }
    
    internal func resolveScoped<T: Sendable>(key: String, metadata: DependencyMetadata) async throws -> T {
        if config.enableCaching, let existing = scopedInstances[scopeId]?[key] as? T {
            if config.enablePerformanceMetrics {
                cacheHits[key, default: 0] += 1
            }
            return existing
        }
        
        // Create new instance using factory (sync or async)
        guard let factoryType = getFactory(for: key) else {
            throw DependencyResolutionError.factoryError("No factory found for \(key)")
        }
        
        let sendableInstance: Sendable
        switch factoryType {
        case .sync(let syncFactory):
            sendableInstance = try syncFactory(self)
        case .async(let asyncFactory):
            sendableInstance = try await asyncFactory(self)
        }
        
        guard let instance = sendableInstance as? T else {
            let actualType = String(describing: type(of: sendableInstance))
            throw DependencyResolutionError.typeMismatch("Factory returned \(actualType) but expected \(key)")
        }
        if config.enableCaching {
            if scopedInstances[scopeId] == nil {
                scopedInstances[scopeId] = [:]
            }
            scopedInstances[scopeId]![key] = instance
        }
        
        return instance
    }
    
    internal func resolveTransient<T: Sendable>(key: String, metadata: DependencyMetadata) async throws -> T {
        // Create new instance using factory (sync or async)
        guard let factoryType = getFactory(for: key) else {
            throw DependencyResolutionError.factoryError("No factory found for \(key)")
        }
        
        let sendableInstance: Sendable
        switch factoryType {
        case .sync(let syncFactory):
            sendableInstance = try syncFactory(self)
        case .async(let asyncFactory):
            sendableInstance = try await asyncFactory(self)
        }
        
        guard let instance = sendableInstance as? T else {
            let actualType = String(describing: type(of: sendableInstance))
            throw DependencyResolutionError.typeMismatch("Factory returned \(actualType) but expected \(key)")
        }
        return instance
    }
    
    internal func resolveLazy<T: Sendable>(key: String, metadata: DependencyMetadata) async throws -> T {
        if config.enableCaching, let existing = lazyInstances[key] as? T {
            if config.enablePerformanceMetrics {
                cacheHits[key, default: 0] += 1
            }
            return existing
        }
        
        // Create new instance using factory (sync or async)
        guard let factoryType = getFactory(for: key) else {
            throw DependencyResolutionError.factoryError("No factory found for \(key)")
        }
        
        let sendableInstance: Sendable
        switch factoryType {
        case .sync(let syncFactory):
            sendableInstance = try syncFactory(self)
        case .async(let asyncFactory):
            sendableInstance = try await asyncFactory(self)
        }
        
        guard let instance = sendableInstance as? T else {
            let actualType = String(describing: type(of: sendableInstance))
            throw DependencyResolutionError.typeMismatch("Factory returned \(actualType) but expected \(key)")
        }
        if config.enableCaching {
            lazyInstances[key] = instance
        }
        
        return instance
    }
}
