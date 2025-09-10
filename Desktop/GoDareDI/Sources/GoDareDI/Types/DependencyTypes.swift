//
//  DependencyTypes.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - Core Dependency Types
public enum DependencyScope: String, CaseIterable, Codable, Sendable {
    case singleton = "singleton"
    case scoped = "scoped"
    case transient = "transient"
    case lazy = "lazy"
}

public enum DependencyLifetime: String, Hashable, CaseIterable, Codable, Sendable {
    case application = "application"
    case session = "session"
    case request = "request"
    case custom = "custom"
}

public struct DependencyMetadata: Codable, Sendable {
    let type: String // Store as string for Codable support
    public let scope: DependencyScope
    public let lifetime: DependencyLifetime
    let lazy: Bool
    let dependencies: [String] // Track what this type depends on
    let registrationTime: Date
    let lastAccessed: Date?
    
    init(type: Any.Type, scope: DependencyScope, lifetime: DependencyLifetime, lazy: Bool = false, dependencies: [String] = []) {
        self.type = String(describing: type)
        self.scope = scope
        self.lifetime = lifetime
        self.lazy = lazy
        self.dependencies = dependencies
        self.registrationTime = Date()
        self.lastAccessed = nil
    }
    
    mutating func updateLastAccessed() {
        // Note: This would need to be handled differently in a real implementation
        // since structs are value types
    }
}

// MARK: - Performance Metrics
public struct PerformanceMetrics: Codable, Sendable {
    public let averageResolutionTime: TimeInterval
    public let cacheHitRate: Double
    public let memoryUsage: Double
    public let totalResolutions: Int
    public let circularDependencyCount: Int
    
    public init(averageResolutionTime: TimeInterval, cacheHitRate: Double, memoryUsage: Double, totalResolutions: Int, circularDependencyCount: Int) {
        self.averageResolutionTime = averageResolutionTime
        self.cacheHitRate = cacheHitRate
        self.memoryUsage = memoryUsage
        self.totalResolutions = totalResolutions
        self.circularDependencyCount = circularDependencyCount
    }
}
