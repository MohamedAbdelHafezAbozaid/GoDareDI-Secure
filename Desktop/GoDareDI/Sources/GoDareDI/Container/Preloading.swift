//
//  Preloading.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Preloading Extensions
@available(iOS 18.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Performance and Monitoring
    public func preloadDependencies() async {
        print("🚀 Preloading critical dependencies...")
        
        // ✅ Preload ALL services, not just singletons
        for (key, meta) in typeRegistry {
            do {
                switch meta.scope {
                case .singleton:
                    let _: any Sendable = try await resolveInternal(key: key)
                    print("✅ Preloaded singleton: \(key)")
                case .scoped:
                    let _: any Sendable = try await resolveInternal(key: key)
                    print("✅ Preloaded scoped: \(key)")
                case .lazy:
                    let _: any Sendable = try await resolveInternal(key: key)
                    print("✅ Preloaded lazy: \(key)")
                case .transient:
                    // Skip transient - they can't be cached
                    print("⏭️ Skipped transient: \(key)")
                }
            } catch {
                print("⚠️ Failed to preload: \(key) - \(error)")
            }
        }
        
        print("✅ Dependency preloading completed")
    }
    
    // MARK: - Generic Preloading Implementation
    public func preloadAllGeneric() async throws {
        print("🚀 Starting generic preloading...")
        
        for (key, metadata) in typeRegistry {
            print(" Preloading: \(key) with scope: \(metadata.scope)")
            
            do {
                switch metadata.scope {
                case .singleton, .scoped, .lazy:
                    // ✅ DIRECT FACTORY EXECUTION: Execute factory and cache result
                    if let factoryType = factories[key] {
                        let instance: Sendable
                        switch factoryType {
                        case .sync(let syncFactory):
                            instance = try syncFactory(self)
                        case .async(let asyncFactory):
                            instance = try await asyncFactory(self)
                        }
                        
                        // ✅ MANUALLY CACHE based on scope
                        switch metadata.scope {
                        case .singleton:
                            singletons[key] = instance
                            print("✅ Cached singleton: \(key)")
                        case .scoped:
                            if scopedInstances[scopeId] == nil {
                                scopedInstances[scopeId] = [:]
                            }
                            scopedInstances[scopeId]![key] = instance
                            print("✅ Cached scoped: \(key)")
                        case .lazy:
                            lazyInstances[key] = instance
                            print("✅ Cached lazy: \(key)")
                        case .transient:
                            break
                        }
                    }
                case .transient:
                    print("⏭️ Skipping transient: \(key)")
                }
            } catch {
                print("⚠️ Failed to preload: \(key) - \(error)")
            }
        }
        
        print("✅ Generic preloading completed")
    }
    
    public func preloadSmart() async throws {
        print("🚀 Smart preloading - analyzing dependency tree...")
        
        let allKeys = Array(factories.keys)
        
        // Categorize types automatically
        let categories = categorizeTypes(allKeys)
        
        // Preload in dependency order
        for (category, keys) in categories {
            print("🔄 Preloading \(category) (\(keys.count) items)...")
            try await preloadCategory(keys, category: category)
        }
        
        print("✅ Smart preloading complete!")
    }
    
    public func preloadViewModelsOnly() async throws {
        print("🚀 Preloading ViewModels and their dependencies...")
        
        let allKeys = Array(factories.keys)
        
        // Categorize and preload ViewModels + dependencies
        let categories = categorizeTypes(allKeys)
        
        // Preload in dependency order (ViewModels last)
        let viewModelKeys = categories["ViewModels"] ?? []
        let otherKeys = categories.filter { $0.key != "ViewModels" }.values.flatMap { $0 }
        
        // 1. Preload core dependencies first
        for key in otherKeys {
            try await preloadSingleDependency(key)
        }
        
        // 2. Preload ViewModels (now all deps are cached)
        for key in viewModelKeys {
            try await preloadSingleDependency(key)
        }
        
        print("✅ ViewModels preloaded - resolveSync works everywhere!")
    }
    
    // MARK: - Helper Methods for Generic Preloading
    private func resolveByKey(_ key: String) async throws -> Sendable {
        // 🚀 GENERIC: Use the type registry to resolve any registered type
        guard let type = typeRegistry[key] else {
            throw DependencyResolutionError.notRegistered(key)
        }
        
        // Use type erasure to resolve the actual type
        return try await resolveGeneric(metadata: type)
    }
    
    private func resolveGeneric(metadata: DependencyMetadata) async throws -> Sendable {
        // Extract the type from metadata
        let key = String(describing: metadata.type)
        
        guard let factoryType = factories[key] else {
            throw DependencyResolutionError.notRegistered(key)
        }
        
        let instance: Sendable
        switch factoryType {
        case .sync(let syncFactory):
            instance = try syncFactory(self)
        case .async(let asyncFactory):
            instance = try await asyncFactory(self)
        }
        
        return instance
    }
    
    private func categorizeTypes(_ keys: [String]) -> [String: [String]] {
        var categories: [String: [String]] = [:]
        
        for key in keys {
            let category: String
            if key.contains("Service") || key.contains("Protocol") {
                category = "Core Services"
            } else if key.contains("API") {
                category = "APIs"
            } else if key.contains("Repository") {
                category = "Repositories"
            } else if key.contains("UseCase") {
                category = "Use Cases"
            } else if key.contains("ViewModel") {
                category = "ViewModels"
            } else {
                category = "Other"
            }
            
            categories[category, default: []].append(key)
        }
        
        return categories
    }
    
    private func preloadCategory(_ keys: [String], category: String) async throws {
        for key in keys {
            try await preloadSingleDependency(key)
        }
    }
    
    private func preloadSingleDependency(_ key: String) async throws {
        do {
            // Use the existing metadata to get the type and resolve it
            if typeRegistry[key] != nil {
                let _ = try await resolveByKey(key)
                print("   ✅ \(key)")
            }
        } catch {
            print("   ❌ \(key) - \(error)")
        }
    }
}
