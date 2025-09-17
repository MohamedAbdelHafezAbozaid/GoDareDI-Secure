//
//  Performance.swift
//  GoDareDI
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Performance Extensions
@available(iOS 18.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    
    // MARK: - Performance and Monitoring
    public func getPerformanceMetrics() async -> PerformanceMetrics {
        let averageResolutionTime = performanceMetrics.values.isEmpty ? 0 : performanceMetrics.values.reduce(0, +) / Double(performanceMetrics.values.count)
        let totalResolutions = resolutionCounts.values.reduce(0, +)
        let totalCacheHits = cacheHits.values.reduce(0, +)
        let cacheHitRate = totalResolutions > 0 ? (Double(totalCacheHits) / Double(totalResolutions)) * 100 : 0
        let memoryUsage = getMemoryUsage()
        let circularDependencyCount = await getCircularDependencyCount()
        
        return PerformanceMetrics(
            averageResolutionTime: averageResolutionTime,
            cacheHitRate: cacheHitRate,
            memoryUsage: memoryUsage,
            totalResolutions: totalResolutions,
            circularDependencyCount: circularDependencyCount
        )
    }
    
    public func cleanup() async {
        print("🧹 Cleaning up container...")
        
        // Clear all instances
        singletons.removeAll()
        scopedInstances.removeAll()
        lazyInstances.removeAll()
        resolutionStack.removeAll()
        
        // Clear performance data
        performanceMetrics.removeAll()
        resolutionCounts.removeAll()
        cacheHits.removeAll()
        
        print("✅ Container cleanup completed")
    }
    
    // MARK: - Internal Debugging Methods
    internal func getMetadataCopy() -> [String: DependencyMetadata] {
        return typeRegistry
    }
    
    internal func analyzeDependencies() -> [String: [String]] {
        var result: [String: [String]] = [:]
        for (key, deps) in dependencyMap {
            result[key] = Array(deps)
        }
        return result
    }
    
    // MARK: - Helper Methods
    internal func calculateLayer(for nodeId: String) -> Int {
        // Simple layer calculation based on naming conventions
        if nodeId.contains("API") {
            return 1
        } else if nodeId.contains("Repository") {
            return 2
        } else if nodeId.contains("UseCase") {
            return 3
        } else if nodeId.contains("ViewModel") {
            return 4
        } else {
            return 0
        }
    }
    
    internal func isPartOfCircularDependency(_ nodeId: String) -> Bool {
        // Check if node is part of any circular dependency
        let circularChains = findCircularDependencies()
        return circularChains.contains { chain in
            chain.contains(nodeId)
        }
    }
    
    internal func isCircularEdge(from: String, to: String) -> Bool {
        // Check if this edge is part of a circular dependency
        let circularChains = findCircularDependencies()
        return circularChains.contains { chain in
            if let fromIndex = chain.firstIndex(of: from),
               let toIndex = chain.firstIndex(of: to) {
                return abs(fromIndex - toIndex) == 1 || (fromIndex == 0 && toIndex == chain.count - 1) || (fromIndex == chain.count - 1 && toIndex == 0)
            }
            return false
        }
    }
    
    private func findCircularDependencies() -> [[String]] {
        // Simple circular dependency detection
        var visited: Set<String> = []
        var recursionStack: Set<String> = []
        var circularDeps: [[String]] = []
        
        for (key, _) in typeRegistry {
            if !visited.contains(key) {
                var path: [String] = []
                dfs(node: key, visited: &visited, recursionStack: &recursionStack, path: &path, circularDeps: &circularDeps)
            }
        }
        
        return circularDeps
    }
    
    private func dfs(node: String, visited: inout Set<String>, recursionStack: inout Set<String>, path: inout [String], circularDeps: inout [[String]]) {
        visited.insert(node)
        recursionStack.insert(node)
        path.append(node)
        
        let dependencies = dependencyMap[node] ?? Set()
        for dependency in dependencies {
            if !visited.contains(dependency) {
                dfs(node: dependency, visited: &visited, recursionStack: &recursionStack, path: &path, circularDeps: &circularDeps)
            } else if recursionStack.contains(dependency) {
                if let startIndex = path.firstIndex(of: dependency) {
                    let cycle = Array(path[startIndex...])
                    circularDeps.append(cycle)
                }
            }
        }
        
        recursionStack.remove(node)
        path.removeLast()
    }
    
    internal func getMemoryUsage() -> Double {
        // Simple memory usage estimation
        let singletonCount = singletons.count
        let scopedCount = scopedInstances.values.reduce(0) { $0 + $1.count }
        let lazyCount = lazyInstances.count
        let metadataCount = typeRegistry.count
        
        // Rough estimation: 1KB per instance
        return Double(singletonCount + scopedCount + lazyCount + metadataCount) * 0.001
    }
    
    internal func calculateCacheEfficiency() -> Double {
        let totalResolutions = resolutionCounts.values.reduce(0, +)
        let totalCacheHits = cacheHits.values.reduce(0, +)
        
        return totalResolutions > 0 ? (Double(totalCacheHits) / Double(totalResolutions)) * 100 : 0
    }
    
    private func getCircularDependencyCount() async -> Int {
        let circularChains = findCircularDependencies()
        return circularChains.count
    }
    
    // MARK: - Debug Methods
    public func debugPrintMetadata() {
        print("🔍 DEBUG: Current container metadata:")
        for (key, metadata) in typeRegistry {
            print("  - \(key): scope=\(metadata.scope), lifetime=\(metadata.lifetime)")
        }
    }
    
    public func debugPrintFactories() {
        print("🔍 DEBUG: Current container factories:")
        for (key, factoryType) in factories {
            switch factoryType {
            case .sync:
                print("  - \(key): sync factory")
            case .async:
                print("  - \(key): async factory")
            }
        }
    }
}

@available(iOS 18.0, macOS 10.15, *)
extension AdvancedDIContainerImpl {
    public func getRegisteredServicesCount() -> Int {
        return factories.count
    }
}
