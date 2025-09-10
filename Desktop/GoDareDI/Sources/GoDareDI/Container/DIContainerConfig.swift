//
//  DIContainerConfig.swift
//  GoDareAdvanced
//
//  Created by mohamed ahmed on 31/08/2025.
//

import Foundation

// MARK: - DI Container Configuration
public struct DIContainerConfig: Sendable {
    public let maxCircularDependencyDepth: Int
    public let enableCircularDependencyDetection: Bool
    public let enableDependencyTracking: Bool
    public let enablePerformanceMetrics: Bool
    public let enableCaching: Bool
    
    public init(
        maxCircularDependencyDepth: Int = 3,
        enableCircularDependencyDetection: Bool = true,
        enableDependencyTracking: Bool = true,
        enablePerformanceMetrics: Bool = true,
        enableCaching: Bool = true
    ) {
        self.maxCircularDependencyDepth = maxCircularDependencyDepth
        self.enableCircularDependencyDetection = enableCircularDependencyDetection
        self.enableDependencyTracking = enableDependencyTracking
        self.enablePerformanceMetrics = enablePerformanceMetrics
        self.enableCaching = enableCaching
    }
    
    // MARK: - Predefined Configurations
    public static let strict = DIContainerConfig(
        maxCircularDependencyDepth: 2,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: true,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
    
    public static let lenient = DIContainerConfig(
        maxCircularDependencyDepth: 5,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: true,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
    
    public static let disabled = DIContainerConfig(
        maxCircularDependencyDepth: 0,
        enableCircularDependencyDetection: false,
        enableDependencyTracking: false,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
    
    public static let performance = DIContainerConfig(
        maxCircularDependencyDepth: 3,
        enableCircularDependencyDetection: true,
        enableDependencyTracking: false,
        enablePerformanceMetrics: true,
        enableCaching: true
    )
}
